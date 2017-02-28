ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgentHR_PositionTaking]
	@custid int, --agentID
	--a2
	@v151apositiontaking_31 smallmoney,
	@v151apositiontaking_32 smallmoney,
	@v151apositiontaking_41 smallmoney,
	@v151apositiontaking_42 smallmoney,
	@v151apositiontaking_51 smallmoney = 0,
	@v151apositiontaking_52 smallmoney = 0,
	@v152apositiontaking_41 smallmoney = 0,
	@v152apositiontaking_42 smallmoney = 0,
	@v152apositiontaking_51 smallmoney = 0,
	@v152apositiontaking_52 smallmoney = 0,
	@v153apositiontaking_51 smallmoney = 0,
	@v153apositiontaking_52 smallmoney = 0,
	--m2
	@v151mpositiontaking_31 smallmoney,
	@v151mpositiontaking_32 smallmoney,
	@v151mpositiontaking_41 smallmoney,
	@v151mpositiontaking_42 smallmoney,
	@v151mpositiontaking_51 smallmoney = 0,
	@v151mpositiontaking_52 smallmoney = 0,
	@v152mpositiontaking_41 smallmoney = 0,
	@v152mpositiontaking_42 smallmoney = 0,
	@v152mpositiontaking_51 smallmoney = 0,
	@v152mpositiontaking_52 smallmoney = 0,
	@v153mpositiontaking_51 smallmoney = 0,
	@v153mpositiontaking_52 smallmoney = 0,
	--um2
	@auto_v151mpositiontaking_31 smallmoney = 0,
	@auto_v151mpositiontaking_32 smallmoney = 0,
	@auto_v151mpositiontaking_41 smallmoney = 0,
	@auto_v151mpositiontaking_42 smallmoney = 0,
	@auto_v151mpositiontaking_51 smallmoney = 0,
	@auto_v151mpositiontaking_52 smallmoney = 0,
	@auto_v152mpositiontaking_41 smallmoney = 0,
	@auto_v152mpositiontaking_42 smallmoney = 0,
	@auto_v152mpositiontaking_51 smallmoney = 0,
	@auto_v152mpositiontaking_52 smallmoney = 0,
	@auto_v153mpositiontaking_51 smallmoney = 0,
	@auto_v153mpositiontaking_52 smallmoney = 0,
	
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

	@IsCopyPreset151_31 bit = 0,-- @IsCopyPreset_31 -> @IsCopyPreset151_31 Use for copy preset to member
	@IsCopyPreset151_41 bit = 0,-- @IsCopyPreset_41 -> @IsCopyPreset151_41 Use for copy preset to member
	@IsCopyPreset151_51 bit = 0,
	@IsCopyPreset152_41 bit = 0,
	@IsCopyPreset152_51 bit = 0,
	@IsCopyPreset153_51 bit = 0,
	@updateallmembers bit = 0,--Use for auto PT
	@newmpositiontaking smallmoney = 0,--equals max(m+a) - chosen(a)

	@UpdateMultiple BIT = 0,
	@UpdatePositiontakingv151_31 BIT = 1,
	@UpdatePositiontakingv151_41 BIT = 1,
	@UpdatePositiontakingv151_51 BIT = 1,
	@UpdatePositiontakingv152_41 BIT = 1,
	@UpdatePositiontakingv152_51 BIT = 1,
	@UpdatePositiontakingv153_51 BIT = 1,	

	@SubAccID int = 0, --Sub-AccountID	
	
	@UserID int = 0,	
	@Language varchar(2) = 'E',
	@IP varchar(15)='',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20090517@Phuc
Task : Update HR's Agent Position Taking
DB: DBTXN/bodb02
Original: Acc_CustomerUpdEditCustomer_MAg

Revisions:
	- 20090610@Phuc: copy master preset to member(m2->m1).
	- 20090630@Phuc: auto master PT on member level.
					Write log subaccname instead of subaccid.
	- 20090917@Phuc: write log into DBLOG.
	- 20091201@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
	- 20100112@Kiwi: Amend to write log in xml format.
	- 20101019@Henry: Record execution time
	- 20110126@Henry: Add setting  
      + AU Horse racing  
      + UK, AU Greyhound racing  
      + AU Harness racing 
	- 20110331@Lukas: include sport name to error messages
	- 20110516@Johnson: write log for old setting
	- 20111018@TOM: Apply Multiple Edit Racing PT.
	- 20111114@TOM: Add parameter input @UpdatePositiontakingv151_31 => _51
								@UpdatePositiontakingv152_41 => _51
					Check edit multiple Racing PT.	
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130226@Johnson: write log on DBTXN if DBLOG failure
	- 20130418@Johnson: check auto posititiontaking negative
	- 20131107@Johnson: Apply execrep when update pt on members	
			and check total downlines before UPDATEs
	- 20131108@Elodie: Splitting bodb02 into CustDB (call sport, bettype by link database)			
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB, Use temp table for sports, bettype table)
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

Declare @UserName nvarchar(20), @mrecommend int, @srecommend int, @maxpos smallmoney
declare @ErrAcc varchar(4000), @ErrType varchar(4000)
Set @maxpos = 0.5 --max pt for HR

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
	
Select @UserName = username, @mrecommend = mrecommend, @srecommend = srecommend 
from custinfo with (NOLOCK) 
where CustID = @CustID
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
declare 
		@old_v151apositiontaking_31 smallmoney,
		@old_v151apositiontaking_32 smallmoney,
		@old_v151apositiontaking_41 smallmoney,
		@old_v151apositiontaking_42 smallmoney,
		@old_v151apositiontaking_51 smallmoney,
		@old_v151apositiontaking_52 smallmoney,
		@old_v152apositiontaking_41 smallmoney,
		@old_v152apositiontaking_42 smallmoney,
		@old_v152apositiontaking_51 smallmoney,
		@old_v152apositiontaking_52 smallmoney,
		@old_v153apositiontaking_51 smallmoney,
		@old_v153apositiontaking_52 smallmoney,
		
		@old_v151mpositiontaking_31 smallmoney,
		@old_v151mpositiontaking_32 smallmoney,
		@old_v151mpositiontaking_41 smallmoney,
		@old_v151mpositiontaking_42 smallmoney,
		@old_v151mpositiontaking_51 smallmoney,
		@old_v151mpositiontaking_52 smallmoney,
		@old_v152mpositiontaking_41 smallmoney,
		@old_v152mpositiontaking_42 smallmoney,
		@old_v152mpositiontaking_51 smallmoney,
		@old_v152mpositiontaking_52 smallmoney,
		@old_v153mpositiontaking_51 smallmoney,
		@old_v153mpositiontaking_52 smallmoney,

		@max_v151mapositiontaking_31 smallmoney,
		@max_v151mapositiontaking_32 smallmoney,
		@max_v151mapositiontaking_41 smallmoney,
		@max_v151mapositiontaking_42 smallmoney,
		@max_v151mapositiontaking_51 smallmoney,
		@max_v151mapositiontaking_52 smallmoney,
		@max_v152mapositiontaking_41 smallmoney,
		@max_v152mapositiontaking_42 smallmoney,
		@max_v152mapositiontaking_51 smallmoney,
		@max_v152mapositiontaking_52 smallmoney,
		@max_v153mapositiontaking_51 smallmoney,
		@max_v153mapositiontaking_52 smallmoney
		
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if (@UpdateMultiple = 0 or @UpdatePositiontakingv151_31 = 1 or @UpdatePositiontakingv151_41 = 1 or @UpdatePositiontakingv151_51 = 1)
BEGIN --@UpdatePositiontakingv151
	if	  ((@v151apositiontaking_31  <0	
		or @v151apositiontaking_32 <0
		or @v151mpositiontaking_31 <0
		or @v151mpositiontaking_32 <0
		or @auto_v151mpositiontaking_31 <0
		or @auto_v151mpositiontaking_32 <0
		or @v151mpositiontaking_31 > @maxpos
		or @v151mpositiontaking_32 > @maxpos
		or @v151apositiontaking_31 + @v151mpositiontaking_31 > @maxpos
		or @v151apositiontaking_32 + @v151mpositiontaking_32 > @maxpos		)
		and @UpdatePositiontakingv151_31 = 1	) 
		
		or ((@v151apositiontaking_41 <0	
		or @v151apositiontaking_42 <0
		or @v151mpositiontaking_41 <0
		or @v151mpositiontaking_42 <0
		or @auto_v151mpositiontaking_41 <0
		or @auto_v151mpositiontaking_42 <0
		or @v151mpositiontaking_41 > @maxpos
		or @v151mpositiontaking_42 > @maxpos			
		or @v151apositiontaking_41 + @v151mpositiontaking_41 > @maxpos
		or @v151apositiontaking_42 + @v151mpositiontaking_42 > @maxpos		)
		and @UpdatePositiontakingv151_41 = 1	) 
		
		or ((@v151apositiontaking_51 <0	
		or @v151apositiontaking_52 <0
		or @v151mpositiontaking_51 <0
		or @v151mpositiontaking_52 <0
		or @auto_v151mpositiontaking_51 <0
		or @auto_v151mpositiontaking_52 <0
		or @v151mpositiontaking_52 > @maxpos
		or @v151mpositiontaking_51 > @maxpos		
		or @v151apositiontaking_51 + @v151mpositiontaking_51 > @maxpos
		or @v151apositiontaking_52 + @v151mpositiontaking_52 > @maxpos		)
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

	--check n3<=m2+a2<=l3 if im2 = 0, 
	--a2<=l3 and um2+a2>=n3 if im2 = 1
	select @ErrType = ''
	select @ErrType = @ErrType + s.SportName + ' - ' +
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	+ '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from CustOverride3rd as co with (NOLOCK) inner join
		(
 						select 31 as bettype, 151 as sporttype, @v151apositiontaking_31 as apositiontaking, @v151mpositiontaking_31 as mpositiontaking, @isauto_v151mpositiontaking_31 as isauto_mpositiontaking, @auto_v151mpositiontaking_31 as auto_mpositiontaking WHERE @UpdatePositiontakingv151_31 = 1		
 			union all	select 32 as bettype, 151 as sporttype, @v151apositiontaking_32 as apositiontaking, @v151mpositiontaking_32 as mpositiontaking, @isauto_v151mpositiontaking_32 as isauto_mpositiontaking, @auto_v151mpositiontaking_32 as auto_mpositiontaking WHERE @UpdatePositiontakingv151_31 = 1
 			union all	select 41 as bettype, 151 as sporttype, @v151apositiontaking_41 as apositiontaking, @v151mpositiontaking_41 as mpositiontaking, @isauto_v151mpositiontaking_41 as isauto_mpositiontaking, @auto_v151mpositiontaking_41 as auto_mpositiontaking WHERE @UpdatePositiontakingv151_41 = 1
 			union all	select 42 as bettype, 151 as sporttype, @v151apositiontaking_42 as apositiontaking, @v151mpositiontaking_42 as mpositiontaking, @isauto_v151mpositiontaking_42 as isauto_mpositiontaking, @auto_v151mpositiontaking_42 as auto_mpositiontaking WHERE @UpdatePositiontakingv151_41 = 1
 			union all	select 51 as bettype, 151 as sporttype, @v151apositiontaking_51 as apositiontaking, @v151mpositiontaking_51 as mpositiontaking, @isauto_v151mpositiontaking_51 as isauto_mpositiontaking, @auto_v151mpositiontaking_51 as auto_mpositiontaking WHERE @UpdatePositiontakingv151_51 = 1
 			union all	select 52 as bettype, 151 as sporttype, @v151apositiontaking_52 as apositiontaking, @v151mpositiontaking_52 as mpositiontaking, @isauto_v151mpositiontaking_52 as isauto_mpositiontaking, @auto_v151mpositiontaking_52 as auto_mpositiontaking WHERE @UpdatePositiontakingv151_51 = 1
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	where co.custid = @mrecommend and (	
						((b.isauto_mpositiontaking=0) and (b.mpositiontaking+b.apositiontaking>co.maxpositiontaking or b.mpositiontaking+b.apositiontaking<co.minpositiontaking)) or 
						(b.isauto_mpositiontaking>0 and (b.apositiontaking>co.maxpositiontaking or b.apositiontaking + b.auto_mpositiontaking<co.minpositiontaking))
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = @UserName + ': '+
				case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--n2<=a2<=l2
	select @ErrType = ''
	select @ErrType = @ErrType + s.SportName + ' - ' +
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	 + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from CustOverride3rd as co with (NOLOCK) inner join
		(
			 			select 31 as bettype, 151 as sporttype, @v151apositiontaking_31 as apositiontaking, @v151mpositiontaking_31 as mpositiontaking WHERE @UpdatePositiontakingv151_31 = 1
			union all	select 32 as bettype, 151 as sporttype, @v151apositiontaking_32 as apositiontaking, @v151mpositiontaking_32 as mpositiontaking WHERE @UpdatePositiontakingv151_31 = 1
			union all	select 41 as bettype, 151 as sporttype, @v151apositiontaking_41 as apositiontaking, @v151mpositiontaking_41 as mpositiontaking WHERE @UpdatePositiontakingv151_41 = 1
			union all	select 42 as bettype, 151 as sporttype, @v151apositiontaking_42 as apositiontaking, @v151mpositiontaking_42 as mpositiontaking WHERE @UpdatePositiontakingv151_41 = 1
			union all	select 51 as bettype, 151 as sporttype, @v151apositiontaking_51 as apositiontaking, @v151mpositiontaking_51 as mpositiontaking WHERE @UpdatePositiontakingv151_51 = 1
			union all	select 52 as bettype, 151 as sporttype, @v151apositiontaking_52 as apositiontaking, @v151mpositiontaking_52 as mpositiontaking WHERE @UpdatePositiontakingv151_51 = 1

		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	where co.custid = @custid and (	
						(b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking)
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 12
		Select @ErrMsg = 	@UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType							
					end
		return
	END

	--check a2<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + s.SportName + ' - ' +
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	 + '-Max: '+ cast((scs.apositiontaking) as varchar(10)) + '<br>'
	from custinfo as c with (NOLOCK) inner join CustSetting3rd as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
						select 31 as bettype, 151 as sporttype, @v151apositiontaking_31 as apositiontaking, @v151mpositiontaking_31 as mpositiontaking WHERE @UpdatePositiontakingv151_31 = 1
			union all	select 32 as bettype, 151 as sporttype, @v151apositiontaking_32 as apositiontaking, @v151mpositiontaking_32 as mpositiontaking WHERE @UpdatePositiontakingv151_31 = 1
			union all	select 41 as bettype, 151 as sporttype, @v151apositiontaking_41 as apositiontaking, @v151mpositiontaking_41 as mpositiontaking WHERE @UpdatePositiontakingv151_41 = 1
			union all	select 42 as bettype, 151 as sporttype, @v151apositiontaking_42 as apositiontaking, @v151mpositiontaking_42 as mpositiontaking WHERE @UpdatePositiontakingv151_41 = 1
			union all	select 51 as bettype, 151 as sporttype, @v151apositiontaking_51 as apositiontaking, @v151mpositiontaking_51 as mpositiontaking WHERE @UpdatePositiontakingv151_51 = 1
			union all	select 52 as bettype, 151 as sporttype, @v151apositiontaking_52 as apositiontaking, @v151mpositiontaking_52 as mpositiontaking WHERE @UpdatePositiontakingv151_51 = 1
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
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
	--End check param
	
	if @UpdatePositiontakingv151_31 = 1
		begin
			select @old_v151mpositiontaking_31 = mpositiontaking, @old_v151apositiontaking_31 = apositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=31 and sporttype=151
			select @old_v151mpositiontaking_32 = mpositiontaking, @old_v151apositiontaking_32 = apositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=32 and sporttype=151
			select @max_v151mapositiontaking_31 =mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=31 and sporttype=151
			select @max_v151mapositiontaking_32 =mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=32 and sporttype=151
		end
	if @UpdatePositiontakingv151_41 = 1
		begin
			select @old_v151mpositiontaking_41 = mpositiontaking, @old_v151apositiontaking_41 = apositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=41 and sporttype=151
			select @old_v151mpositiontaking_42 = mpositiontaking, @old_v151apositiontaking_42 = apositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=42 and sporttype=151		
			select @max_v151mapositiontaking_41 =mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=41 and sporttype=151
			select @max_v151mapositiontaking_42 =mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=42 and sporttype=151			
		end
	if @UpdatePositiontakingv151_51 = 1
		begin
			select @old_v151mpositiontaking_51 = mpositiontaking, @old_v151apositiontaking_51 = apositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=51 and sporttype=151
			select @old_v151mpositiontaking_52 = mpositiontaking, @old_v151apositiontaking_52 = apositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=52 and sporttype=151
			select @max_v151mapositiontaking_51 =mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=51 and sporttype=151
			select @max_v151mapositiontaking_52 =mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=52 and sporttype=151			
		end
		
	select @ErrType = ''
	select @ErrType = @ErrType + s.SportName + ' - ' +
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	+ '-Max: '+ cast((b.max_mapositiontaking) as varchar(10)) + '<br>'
	from
	(				select 31 as bettype, 151 as sporttype, @v151apositiontaking_31 as apositiontaking, @v151mpositiontaking_31 as mpositiontaking, @max_v151mapositiontaking_31 as max_mapositiontaking WHERE @UpdatePositiontakingv151_31 = 1
		union all	select 32 as bettype, 151 as sporttype, @v151apositiontaking_32 as apositiontaking, @v151mpositiontaking_32 as mpositiontaking, @max_v151mapositiontaking_32 as max_mapositiontaking WHERE @UpdatePositiontakingv151_31 = 1
		union all	select 41 as bettype, 151 as sporttype, @v151apositiontaking_41 as apositiontaking, @v151mpositiontaking_41 as mpositiontaking, @max_v151mapositiontaking_41 as max_mapositiontaking WHERE @UpdatePositiontakingv151_41 = 1
		union all	select 42 as bettype, 151 as sporttype, @v151apositiontaking_42 as apositiontaking, @v151mpositiontaking_42 as mpositiontaking, @max_v151mapositiontaking_42 as max_mapositiontaking WHERE @UpdatePositiontakingv151_41 = 1
		union all	select 51 as bettype, 151 as sporttype, @v151apositiontaking_51 as apositiontaking, @v151mpositiontaking_51 as mpositiontaking, @max_v151mapositiontaking_51 as max_mapositiontaking WHERE @UpdatePositiontakingv151_51 = 1
		union all	select 52 as bettype, 151 as sporttype, @v151apositiontaking_52 as apositiontaking, @v151mpositiontaking_52 as mpositiontaking, @max_v151mapositiontaking_52 as max_mapositiontaking WHERE @UpdatePositiontakingv151_51 = 1
	) as b
	INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	where (b.apositiontaking+b.mpositiontaking>b.max_mapositiontaking) 

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

	--check um2<=min(m3,l3) - Phuc@20081209
	select @ErrType = ''
	select @ErrType = @ErrType + s.SportName + ' - ' + 
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	 + '-Max: '+ cast((case when max_mapositiontaking > co.maxpositiontaking then co.maxpositiontaking else max_mapositiontaking end) as varchar(10)) + '<br>'
	from CustOverride3rd co (nolock) inner join 
	(
					select 31 as bettype, 151 as sporttype, @auto_v151mpositiontaking_31 as autopositiontaking, @isauto_v151mpositiontaking_31 as isautopositiontaking, @max_v151mapositiontaking_31 as max_mapositiontaking WHERE @UpdatePositiontakingv151_31 = 1
		union all   select 32 as bettype, 151 as sporttype, @auto_v151mpositiontaking_32 as autopositiontaking, @isauto_v151mpositiontaking_32 as isautopositiontaking, @max_v151mapositiontaking_32 as max_mapositiontaking WHERE @UpdatePositiontakingv151_31 = 1
		union all   select 41 as bettype, 151 as sporttype, @auto_v151mpositiontaking_41 as autopositiontaking, @isauto_v151mpositiontaking_41 as isautopositiontaking, @max_v151mapositiontaking_41 as max_mapositiontaking WHERE @UpdatePositiontakingv151_41 = 1
		union all   select 42 as bettype, 151 as sporttype, @auto_v151mpositiontaking_42 as autopositiontaking, @isauto_v151mpositiontaking_42 as isautopositiontaking, @max_v151mapositiontaking_42 as max_mapositiontaking WHERE @UpdatePositiontakingv151_41 = 1
		union all   select 51 as bettype, 151 as sporttype, @auto_v151mpositiontaking_51 as autopositiontaking, @isauto_v151mpositiontaking_51 as isautopositiontaking, @max_v151mapositiontaking_51 as max_mapositiontaking WHERE @UpdatePositiontakingv151_51 = 1
		union all   select 52 as bettype, 151 as sporttype, @auto_v151mpositiontaking_52 as autopositiontaking, @isauto_v151mpositiontaking_52 as isautopositiontaking, @max_v151mapositiontaking_52 as max_mapositiontaking WHERE @UpdatePositiontakingv151_51 = 1
	) as b on b.sporttype = co.sporttype and b.bettype = co.bettype
	INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	where co.custid = @mrecommend and
	(
		  (	b.isautopositiontaking = 1 
			and b.autopositiontaking > case when max_mapositiontaking > co.maxpositiontaking then co.maxpositiontaking else max_mapositiontaking end
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
END --@UpdatePositiontakingv151

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if (@UpdateMultiple = 0 or @UpdatePositiontakingv152_41 = 1 or @UpdatePositiontakingv152_51 = 1)
BEGIN --@UpdatePositiontakingv152
	if  ((@v152apositiontaking_41    <0	
		or @v152apositiontaking_42 <0
		or @v152mpositiontaking_41 <0
		or @v152mpositiontaking_42 <0		
		or @auto_v152mpositiontaking_41 <0
		or @auto_v152mpositiontaking_42 <0
		or @v152mpositiontaking_41 > @maxpos		
		or @v152mpositiontaking_42 > @maxpos
		or @v152apositiontaking_41 + @v152mpositiontaking_41 > @maxpos
		or @v152apositiontaking_42 + @v152mpositiontaking_42 > @maxpos		)
		and @UpdatePositiontakingv152_41 = 1	)
		
		or ((@v152apositiontaking_51 <0
		or @v152apositiontaking_52 <0
		or @v152mpositiontaking_51 <0
		or @v152mpositiontaking_52 <0
		or @auto_v152mpositiontaking_51 <0
		or @auto_v152mpositiontaking_52 <0
		or @v152mpositiontaking_51 > @maxpos	
		or @v152mpositiontaking_52 > @maxpos		
		or @v152apositiontaking_52 + @v152mpositiontaking_52 > @maxpos
		or @v152apositiontaking_51 + @v152mpositiontaking_51 > @maxpos		)
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

	--check n3<=m2+a2<=l3 if im2 = 0, 
	--a2<=l3 and um2+a2>=n3 if im2 = 1
	select @ErrType = ''
	select @ErrType = @ErrType + s.SportName + ' - ' +
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	+ '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from CustOverride3rd as co with (NOLOCK) inner join
		(				select 41 as bettype, 152 as sporttype, @v152apositiontaking_41 as apositiontaking, @v152mpositiontaking_41 as mpositiontaking, @isauto_v152mpositiontaking_41 as isauto_mpositiontaking, @auto_v152mpositiontaking_41 as auto_mpositiontaking WHERE @UpdatePositiontakingv152_41 = 1
 			union all	select 42 as bettype, 152 as sporttype, @v152apositiontaking_42 as apositiontaking, @v152mpositiontaking_42 as mpositiontaking, @isauto_v152mpositiontaking_42 as isauto_mpositiontaking, @auto_v152mpositiontaking_42 as auto_mpositiontaking WHERE @UpdatePositiontakingv152_41 = 1
 			union all	select 51 as bettype, 152 as sporttype, @v152apositiontaking_51 as apositiontaking, @v152mpositiontaking_51 as mpositiontaking, @isauto_v152mpositiontaking_51 as isauto_mpositiontaking, @auto_v152mpositiontaking_51 as auto_mpositiontaking WHERE @UpdatePositiontakingv152_51 = 1
 			union all	select 52 as bettype, 152 as sporttype, @v152apositiontaking_52 as apositiontaking, @v152mpositiontaking_52 as mpositiontaking, @isauto_v152mpositiontaking_52 as isauto_mpositiontaking, @auto_v152mpositiontaking_52 as auto_mpositiontaking WHERE @UpdatePositiontakingv152_51 = 1
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	where co.custid = @mrecommend and (	
						((b.isauto_mpositiontaking=0) and (b.mpositiontaking+b.apositiontaking>co.maxpositiontaking or b.mpositiontaking+b.apositiontaking<co.minpositiontaking)) or 
						(b.isauto_mpositiontaking>0 and (b.apositiontaking>co.maxpositiontaking or b.apositiontaking + b.auto_mpositiontaking<co.minpositiontaking))
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = @UserName + ': '+
				case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--n2<=a2<=l2
	select @ErrType = ''
	select @ErrType = @ErrType + s.SportName + ' - ' +
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	 + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from CustOverride3rd as co with (NOLOCK) inner join
		(				select 41 as bettype, 152 as sporttype, @v152apositiontaking_41 as apositiontaking, @v152mpositiontaking_41 as mpositiontaking WHERE @UpdatePositiontakingv152_41 = 1
			union all	select 42 as bettype, 152 as sporttype, @v152apositiontaking_42 as apositiontaking, @v152mpositiontaking_42 as mpositiontaking WHERE @UpdatePositiontakingv152_41 = 1
			union all	select 51 as bettype, 152 as sporttype, @v152apositiontaking_51 as apositiontaking, @v152mpositiontaking_51 as mpositiontaking WHERE @UpdatePositiontakingv152_51 = 1
			union all	select 52 as bettype, 152 as sporttype, @v152apositiontaking_52 as apositiontaking, @v152mpositiontaking_52 as mpositiontaking WHERE @UpdatePositiontakingv152_51 = 1
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	where co.custid = @custid and (	
						(b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking)
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 12
		Select @ErrMsg = 	@UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a2<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + s.SportName + ' - ' +
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	 + '-Max: '+ cast((scs.apositiontaking) as varchar(10)) + '<br>'
	from custinfo as c with (NOLOCK) inner join CustSetting3rd as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(				select 41 as bettype, 152 as sporttype, @v152apositiontaking_41 as apositiontaking, @v152mpositiontaking_41 as mpositiontaking WHERE @UpdatePositiontakingv152_41 = 1
			union all	select 42 as bettype, 152 as sporttype, @v152apositiontaking_42 as apositiontaking, @v152mpositiontaking_42 as mpositiontaking WHERE @UpdatePositiontakingv152_41 = 1
			union all	select 51 as bettype, 152 as sporttype, @v152apositiontaking_51 as apositiontaking, @v152mpositiontaking_51 as mpositiontaking WHERE @UpdatePositiontakingv152_51 = 1
			union all	select 52 as bettype, 152 as sporttype, @v152apositiontaking_52 as apositiontaking, @v152mpositiontaking_52 as mpositiontaking WHERE @UpdatePositiontakingv152_51 = 1
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
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
	
	if (@UpdatePositiontakingv152_41 = 1)
		begin		
			select @old_v152mpositiontaking_41 = mpositiontaking, @old_v152apositiontaking_41 = apositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=41 and sporttype=152
			select @old_v152mpositiontaking_42 = mpositiontaking, @old_v152apositiontaking_42 = apositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=42 and sporttype=152
			select @max_v152mapositiontaking_41 =mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=41 and sporttype=152
			select @max_v152mapositiontaking_42 =mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=42 and sporttype=152
		end
	if (@UpdatePositiontakingv152_51 = 1)
		begin		
			select @old_v152mpositiontaking_51 = mpositiontaking, @old_v152apositiontaking_51 = apositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=51 and sporttype=152
			select @old_v152mpositiontaking_52 = mpositiontaking, @old_v152apositiontaking_52 = apositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=52 and sporttype=152
			select @max_v152mapositiontaking_51 =mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=51 and sporttype=152
			select @max_v152mapositiontaking_52 =mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=52 and sporttype=152
		end
		
	select @ErrType = ''
	select @ErrType = @ErrType + s.SportName + ' - ' +
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	+ '-Max: '+ cast((b.max_mapositiontaking) as varchar(10)) + '<br>'
	from
	(				select 41 as bettype, 152 as sporttype, @v152apositiontaking_41 as apositiontaking, @v152mpositiontaking_41 as mpositiontaking, @max_v152mapositiontaking_41 as max_mapositiontaking WHERE @UpdatePositiontakingv152_41 = 1
		union all	select 42 as bettype, 152 as sporttype, @v152apositiontaking_42 as apositiontaking, @v152mpositiontaking_42 as mpositiontaking, @max_v152mapositiontaking_42 as max_mapositiontaking WHERE @UpdatePositiontakingv152_41 = 1
		union all	select 51 as bettype, 152 as sporttype, @v152apositiontaking_51 as apositiontaking, @v152mpositiontaking_51 as mpositiontaking, @max_v152mapositiontaking_51 as max_mapositiontaking WHERE @UpdatePositiontakingv152_51 = 1	
		union all	select 52 as bettype, 152 as sporttype, @v152apositiontaking_52 as apositiontaking, @v152mpositiontaking_52 as mpositiontaking, @max_v152mapositiontaking_52 as max_mapositiontaking WHERE @UpdatePositiontakingv152_51 = 1
	) as b
	INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	where (b.apositiontaking+b.mpositiontaking>b.max_mapositiontaking) 

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

	--check um2<=min(m3,l3) - Phuc@20081209
	select @ErrType = ''
	select @ErrType = @ErrType + s.SportName + ' - ' + 
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	 + '-Max: '+ cast((case when max_mapositiontaking > co.maxpositiontaking then co.maxpositiontaking else max_mapositiontaking end) as varchar(10)) + '<br>'
	from CustOverride3rd co (nolock) inner join 
	(				select 41 as bettype, 152 as sporttype, @auto_v152mpositiontaking_41 as autopositiontaking, @isauto_v152mpositiontaking_41 as isautopositiontaking, @max_v152mapositiontaking_41 as max_mapositiontaking WHERE @UpdatePositiontakingv152_41 = 1
		union all   select 42 as bettype, 152 as sporttype, @auto_v152mpositiontaking_42 as autopositiontaking, @isauto_v152mpositiontaking_42 as isautopositiontaking, @max_v152mapositiontaking_42 as max_mapositiontaking WHERE @UpdatePositiontakingv152_41 = 1
		union all   select 51 as bettype, 152 as sporttype, @auto_v152mpositiontaking_51 as autopositiontaking, @isauto_v152mpositiontaking_51 as isautopositiontaking, @max_v152mapositiontaking_51 as max_mapositiontaking WHERE @UpdatePositiontakingv152_51 = 1
		union all   select 52 as bettype, 152 as sporttype, @auto_v152mpositiontaking_52 as autopositiontaking, @isauto_v152mpositiontaking_52 as isautopositiontaking, @max_v152mapositiontaking_52 as max_mapositiontaking WHERE @UpdatePositiontakingv152_51 = 1
	) as b on b.sporttype = co.sporttype and b.bettype = co.bettype
	INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	where co.custid = @mrecommend and
	(
		  (	b.isautopositiontaking = 1 
			and b.autopositiontaking > case when max_mapositiontaking > co.maxpositiontaking then co.maxpositiontaking else max_mapositiontaking end
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
END --@UpdatePositiontakingv152

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Check Param
if (@UpdateMultiple = 0 or @UpdatePositiontakingv153_51 = 1)
BEGIN --@UpdatePositiontakingv153
	if	(  @v153apositiontaking_51  <0	
		or @v153mpositiontaking_52 <0	
		or @v153mpositiontaking_51 <0
		or @v153apositiontaking_52 <0
		or @auto_v153mpositiontaking_51 <0
		or @auto_v153mpositiontaking_52 <0
		or @v153mpositiontaking_51 > @maxpos
		or @v153mpositiontaking_52 > @maxpos		
		or @v153apositiontaking_52 + @v153mpositiontaking_52 > @maxpos
		or @v153apositiontaking_51 + @v153mpositiontaking_51 > @maxpos
		)and @UpdatePositiontakingv153_51 = 1
		
	BEGIN
		select @ErrCode = 8
		Select @ErrMsg = 	@UserName + ': '+
			case @Language 
							when 'E' then 'Wrong position taking.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
					end
		return
	END

	--check n3<=m2+a2<=l3 if im2 = 0, 
	--a2<=l3 and um2+a2>=n3 if im2 = 1
	select @ErrType = ''
	select @ErrType = @ErrType + s.SportName + ' - ' +
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	+ '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from CustOverride3rd as co with (NOLOCK) inner join
		(				select 51 as bettype, 153 as sporttype, @v153apositiontaking_51 as apositiontaking, @v153mpositiontaking_51 as mpositiontaking, @isauto_v153mpositiontaking_51 as isauto_mpositiontaking, @auto_v153mpositiontaking_51 as auto_mpositiontaking WHERE @UpdatePositiontakingv153_51 = 1
 			union all	select 52 as bettype, 153 as sporttype, @v153apositiontaking_52 as apositiontaking, @v153mpositiontaking_52 as mpositiontaking, @isauto_v153mpositiontaking_52 as isauto_mpositiontaking, @auto_v153mpositiontaking_52 as auto_mpositiontaking WHERE @UpdatePositiontakingv153_51 = 1
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	where co.custid = @mrecommend and (	
						((b.isauto_mpositiontaking=0) and (b.mpositiontaking+b.apositiontaking>co.maxpositiontaking or b.mpositiontaking+b.apositiontaking<co.minpositiontaking)) or 
						(b.isauto_mpositiontaking>0 and (b.apositiontaking>co.maxpositiontaking or b.apositiontaking + b.auto_mpositiontaking<co.minpositiontaking))
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = @UserName + ': '+
				case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--n2<=a2<=l2
	select @ErrType = ''
	select @ErrType = @ErrType + s.SportName + ' - ' +
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	 + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from CustOverride3rd as co with (NOLOCK) inner join
		(				select 51 as bettype, 153 as sporttype, @v153apositiontaking_51 as apositiontaking, @v153mpositiontaking_51 as mpositiontaking WHERE @UpdatePositiontakingv153_51 = 1
			union all	select 52 as bettype, 153 as sporttype, @v153apositiontaking_52 as apositiontaking, @v153mpositiontaking_52 as mpositiontaking WHERE @UpdatePositiontakingv153_51 = 1
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	where co.custid = @custid and (	
						(b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking)
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 12
		Select @ErrMsg = 	@UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a2<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + s.SportName + ' - ' +
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	 + '-Max: '+ cast((scs.apositiontaking) as varchar(10)) + '<br>'
	from custinfo as c with (NOLOCK) inner join CustSetting3rd as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
						select 51 as bettype, 153 as sporttype, @v153apositiontaking_51 as apositiontaking, @v153mpositiontaking_51 as mpositiontaking WHERE @UpdatePositiontakingv153_51 = 1
			union all	select 52 as bettype, 153 as sporttype, @v153apositiontaking_52 as apositiontaking, @v153mpositiontaking_52 as mpositiontaking WHERE @UpdatePositiontakingv153_51 = 1
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
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
	--End check param
	if (@UpdatePositiontakingv153_51 = 1)
		begin
			select @old_v153mpositiontaking_51 = mpositiontaking, @old_v153apositiontaking_51 = apositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=51 and sporttype=152
			select @old_v153mpositiontaking_52 = mpositiontaking, @old_v153apositiontaking_52 = apositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=52 and sporttype=153

			select @max_v153mapositiontaking_51 =mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=51 and sporttype=153
			select @max_v153mapositiontaking_52 =mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and bettype=52 and sporttype=153
		end
			
	select @ErrType = ''
	select @ErrType = @ErrType + s.SportName + ' - ' +
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	+ '-Max: '+ cast((b.max_mapositiontaking) as varchar(10)) + '<br>'
	from
	(
					select 51 as bettype, 153 as sporttype, @v153apositiontaking_51 as apositiontaking, @v153mpositiontaking_51 as mpositiontaking, @max_v153mapositiontaking_51 as max_mapositiontaking WHERE @UpdatePositiontakingv153_51 = 1
		union all	select 52 as bettype, 153 as sporttype, @v153apositiontaking_52 as apositiontaking, @v153mpositiontaking_52 as mpositiontaking, @max_v153mapositiontaking_52 as max_mapositiontaking WHERE @UpdatePositiontakingv153_51 = 1
	) as b
	INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	where (b.apositiontaking+b.mpositiontaking>b.max_mapositiontaking) 

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

	--check um2<=min(m3,l3) - Phuc@20081209
	select @ErrType = ''
	select @ErrType = @ErrType + s.SportName + ' - ' + 
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	 + '-Max: '+ cast((case when max_mapositiontaking > co.maxpositiontaking then co.maxpositiontaking else max_mapositiontaking end) as varchar(10)) + '<br>'
	from CustOverride3rd co (nolock) inner join 
	(
					select 51 as bettype, 153 as sporttype, @auto_v153mpositiontaking_51 as autopositiontaking, @isauto_v153mpositiontaking_51 as isautopositiontaking, @max_v153mapositiontaking_51 as max_mapositiontaking WHERE @UpdatePositiontakingv153_51 = 1
		union all   select 52 as bettype, 153 as sporttype, @auto_v153mpositiontaking_52 as autopositiontaking, @isauto_v153mpositiontaking_52 as isautopositiontaking, @max_v153mapositiontaking_52 as max_mapositiontaking WHERE @UpdatePositiontakingv153_51 = 1
	) as b on b.sporttype = co.sporttype and b.bettype = co.bettype
	INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	where co.custid = @mrecommend and
	(
		  (	b.isautopositiontaking = 1 
			and b.autopositiontaking > case when max_mapositiontaking > co.maxpositiontaking then co.maxpositiontaking else max_mapositiontaking end
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
END --@UpdatePositiontakingv153
----------------------------------------------------------------------------------------------------------

if (@UpdateMultiple = 0 or @UpdatePositiontakingv151_31 = 1 or @UpdatePositiontakingv151_41 = 1 or @UpdatePositiontakingv151_51 = 1)
BEGIN --@UpdatePositiontakingv151
	update CustSetting3rd with (ROWLOCK, UPDLOCK)
	set
		apositiontaking = case  
			when bettype=31 and @UpdatePositiontakingv151_31 = 1  then @v151apositiontaking_31 
			when bettype=32 and @UpdatePositiontakingv151_31 = 1  then @v151apositiontaking_32 
			when bettype=41 and @UpdatePositiontakingv151_41 = 1  then @v151apositiontaking_41 
			when bettype=42 and @UpdatePositiontakingv151_41 = 1  then @v151apositiontaking_42 
			when bettype=51 and @UpdatePositiontakingv151_51 = 1  then @v151apositiontaking_51 
			when bettype=52 and @UpdatePositiontakingv151_51 = 1  then @v151apositiontaking_52 
			else apositiontaking end,
		mpositiontaking = case  
			when bettype=31 and @UpdatePositiontakingv151_31 = 1  then @v151mpositiontaking_31 
			when bettype=32 and @UpdatePositiontakingv151_31 = 1  then @v151mpositiontaking_32 
			when bettype=41 and @UpdatePositiontakingv151_41 = 1  then @v151mpositiontaking_41 
			when bettype=42 and @UpdatePositiontakingv151_41 = 1  then @v151mpositiontaking_42 
			when bettype=51 and @UpdatePositiontakingv151_51 = 1  then @v151mpositiontaking_51 
			when bettype=52 and @UpdatePositiontakingv151_51 = 1  then @v151mpositiontaking_52 
			else mpositiontaking end
	where custid=@custid and sporttype = 151
	if (@@error <> 0)
	begin
		
		Select @ErrMsg = @UserName + ':' + 
						case @Language 
							when 'E' then 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end, @ErrCode = 115
		return
	end
END --@UpdatePositiontakingv151

if (@UpdateMultiple = 0 or @UpdatePositiontakingv152_41 = 1 or @UpdatePositiontakingv152_51 = 1 )
BEGIN --@UpdatePositiontakingv152
	update CustSetting3rd with (ROWLOCK, UPDLOCK)
	set
		apositiontaking = case  
			when bettype=41 and @UpdatePositiontakingv152_41 = 1 then @v152apositiontaking_41 
			when bettype=42 and @UpdatePositiontakingv152_41 = 1 then @v152apositiontaking_42 
			when bettype=51 and @UpdatePositiontakingv152_51 = 1 then @v152apositiontaking_51 
			when bettype=52 and @UpdatePositiontakingv152_51 = 1 then @v152apositiontaking_52 
			else apositiontaking end,
		mpositiontaking = case 
			when bettype=41 and @UpdatePositiontakingv152_41 = 1 then @v152mpositiontaking_41 
			when bettype=42 and @UpdatePositiontakingv152_41 = 1 then @v152mpositiontaking_42 
			when bettype=51 and @UpdatePositiontakingv152_51 = 1 then @v152mpositiontaking_51 
			when bettype=52 and @UpdatePositiontakingv152_51 = 1 then @v152mpositiontaking_52 
			else mpositiontaking end
	where custid=@custid and sporttype = 152
	if (@@error <> 0)
	begin
		
		Select @ErrMsg = @UserName + ':' + 
						case @Language 
							when 'E' then 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end, @ErrCode = 115
		return
	end
END--@UpdatePositiontakingv152

if (@UpdateMultiple = 0 or @UpdatePositiontakingv153_51 = 1)
BEGIN --@UpdatePositiontakingv153
	update CustSetting3rd with (ROWLOCK, UPDLOCK)
	set
		apositiontaking = case 
			when bettype=51 and @UpdatePositiontakingv153_51 = 1 then @v153apositiontaking_51 
			when bettype=52 and @UpdatePositiontakingv153_51 = 1 then @v153apositiontaking_52 
			else apositiontaking end,
		mpositiontaking = case
			when bettype=51 and @UpdatePositiontakingv153_51 = 1 then @v153mpositiontaking_51 
			when bettype=52 and @UpdatePositiontakingv153_51 = 1 then @v153mpositiontaking_52 
			else mpositiontaking end
	where custid=@custid and sporttype = 153
	if (@@error <> 0)
	begin
		
		Select @ErrMsg = @UserName + ':' + 
						case @Language 
							when 'E' then 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end, @ErrCode = 115
		return
	end
END --@UpdatePositiontakingv153
--Cal Auto Positiontaking for Master
Declare 
	@old_auto_v151mpositiontaking_31 smallmoney,
	@old_auto_v151mpositiontaking_32 smallmoney,
	@old_auto_v151mpositiontaking_41 smallmoney,
	@old_auto_v151mpositiontaking_42 smallmoney,
	@old_auto_v151mpositiontaking_51 smallmoney,
	@old_auto_v151mpositiontaking_52 smallmoney,
	@old_auto_v152mpositiontaking_41 smallmoney,
	@old_auto_v152mpositiontaking_42 smallmoney,
	@old_auto_v152mpositiontaking_51 smallmoney,
	@old_auto_v152mpositiontaking_52 smallmoney,
	@old_auto_v153mpositiontaking_51 smallmoney,
	@old_auto_v153mpositiontaking_52 smallmoney,
	
	@old_isauto_v151mpositiontaking_31 bit,
	@old_isauto_v151mpositiontaking_32 bit,
	@old_isauto_v151mpositiontaking_41 bit,
	@old_isauto_v151mpositiontaking_42 bit,
	@old_isauto_v151mpositiontaking_51 bit,
	@old_isauto_v151mpositiontaking_52 bit,
	@old_isauto_v152mpositiontaking_41 bit,
	@old_isauto_v152mpositiontaking_42 bit,
	@old_isauto_v152mpositiontaking_51 bit,
	@old_isauto_v152mpositiontaking_52 bit,
	@old_isauto_v153mpositiontaking_51 bit,
	@old_isauto_v153mpositiontaking_52 bit

--------------------------------------------------------
--Get old Auto PT from Agent
if (@UpdatePositiontakingv151_31 = 1)
	begin
		select 	@old_auto_v151mpositiontaking_31 = autompositiontaking, @old_isauto_v151mpositiontaking_31 = isautompositiontaking	from CustSetting3rd with (nolock) where custid = @custid and sporttype=151 and bettype= 31
		select 	@old_auto_v151mpositiontaking_32 = autompositiontaking, @old_isauto_v151mpositiontaking_32 = isautompositiontaking	from CustSetting3rd with (nolock) where custid = @custid and sporttype=151 and bettype= 32
	end
if (@UpdatePositiontakingv151_41 = 1)
	begin
		select 	@old_auto_v151mpositiontaking_41 = autompositiontaking, @old_isauto_v151mpositiontaking_41 = isautompositiontaking	from CustSetting3rd with (nolock) where custid = @custid and sporttype=151 and bettype= 41
		select 	@old_auto_v151mpositiontaking_42 = autompositiontaking, @old_isauto_v151mpositiontaking_42 = isautompositiontaking	from CustSetting3rd with (nolock) where custid = @custid and sporttype=151 and bettype= 42
	end	
if (@UpdatePositiontakingv151_51 = 1)
	begin	
		select 	@old_auto_v151mpositiontaking_51 = autompositiontaking, @old_isauto_v151mpositiontaking_51 = isautompositiontaking	from CustSetting3rd with (nolock) where custid = @custid and sporttype=151 and bettype= 51
		select 	@old_auto_v151mpositiontaking_52 = autompositiontaking, @old_isauto_v151mpositiontaking_52 = isautompositiontaking	from CustSetting3rd with (nolock) where custid = @custid and sporttype=151 and bettype= 52
	end
if (@UpdatePositiontakingv152_41 = 1)
	begin	
		select 	@old_auto_v152mpositiontaking_41 = autompositiontaking, @old_isauto_v152mpositiontaking_41 = isautompositiontaking	from CustSetting3rd with (nolock) where custid = @custid and sporttype=152 and bettype= 41
		select 	@old_auto_v152mpositiontaking_42 = autompositiontaking, @old_isauto_v152mpositiontaking_42 = isautompositiontaking	from CustSetting3rd with (nolock) where custid = @custid and sporttype=152 and bettype= 42
	end
if (@UpdatePositiontakingv152_51 = 1)
	begin	
		select 	@old_auto_v152mpositiontaking_51 = autompositiontaking, @old_isauto_v152mpositiontaking_51 = isautompositiontaking	from CustSetting3rd with (nolock) where custid = @custid and sporttype=152 and bettype= 51
		select 	@old_auto_v152mpositiontaking_52 = autompositiontaking, @old_isauto_v152mpositiontaking_52 = isautompositiontaking	from CustSetting3rd with (nolock) where custid = @custid and sporttype=152 and bettype= 52
	end
if (@UpdatePositiontakingv153_51 = 1)
	begin		
		select 	@old_auto_v153mpositiontaking_51 = autompositiontaking, @old_isauto_v153mpositiontaking_51 = isautompositiontaking	from CustSetting3rd with (nolock) where custid = @custid and sporttype=153 and bettype= 51
		select 	@old_auto_v153mpositiontaking_52 = autompositiontaking, @old_isauto_v153mpositiontaking_52 = isautompositiontaking	from CustSetting3rd with (nolock) where custid = @custid and sporttype=153 and bettype= 52
	end
--Update Master Agent account
update CustSetting3rd with (ROWLOCK, UPDLOCK) 
set autompositiontaking = CASE WHEN @UpdateMultiple = 1 
								AND (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
									OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
									OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
								THEN  cs.autompositiontaking
							ELSE b.autopositiontaking END, 
	isautompositiontaking = CASE WHEN @UpdateMultiple = 1 
								AND (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
									OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
									OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
								THEN  cs.isautompositiontaking
							ELSE b.isautopositiontaking END
from CustSetting3rd as cs inner join 
		(
						select 31 as bettype,151 as sporttype, @auto_v151mpositiontaking_31 as autopositiontaking, @isauto_v151mpositiontaking_31 as isautopositiontaking WHERE @UpdatePositiontakingv151_31 = 1
			union all	select 32 as bettype,151 as sporttype, @auto_v151mpositiontaking_32 as autopositiontaking, @isauto_v151mpositiontaking_32 as isautopositiontaking WHERE @UpdatePositiontakingv151_31 = 1
			union all	select 41 as bettype,151 as sporttype, @auto_v151mpositiontaking_41 as autopositiontaking, @isauto_v151mpositiontaking_41 as isautopositiontaking WHERE @UpdatePositiontakingv151_41 = 1
			union all	select 42 as bettype,151 as sporttype, @auto_v151mpositiontaking_42 as autopositiontaking, @isauto_v151mpositiontaking_42 as isautopositiontaking WHERE @UpdatePositiontakingv151_41 = 1
			union all	select 51 as bettype,151 as sporttype, @auto_v151mpositiontaking_51 as autopositiontaking, @isauto_v151mpositiontaking_51 as isautopositiontaking WHERE @UpdatePositiontakingv151_51 = 1
			union all	select 52 as bettype,151 as sporttype, @auto_v151mpositiontaking_52 as autopositiontaking, @isauto_v151mpositiontaking_52 as isautopositiontaking WHERE @UpdatePositiontakingv151_51 = 1
			union all	select 41 as bettype,152 as sporttype, @auto_v152mpositiontaking_41 as autopositiontaking, @isauto_v152mpositiontaking_41 as isautopositiontaking WHERE @UpdatePositiontakingv152_41 = 1
			union all	select 42 as bettype,152 as sporttype, @auto_v152mpositiontaking_42 as autopositiontaking, @isauto_v152mpositiontaking_42 as isautopositiontaking WHERE @UpdatePositiontakingv152_41 = 1
			union all	select 51 as bettype,152 as sporttype, @auto_v152mpositiontaking_51 as autopositiontaking, @isauto_v152mpositiontaking_51 as isautopositiontaking WHERE @UpdatePositiontakingv152_51 = 1
			union all	select 52 as bettype,152 as sporttype, @auto_v152mpositiontaking_52 as autopositiontaking, @isauto_v152mpositiontaking_52 as isautopositiontaking WHERE @UpdatePositiontakingv152_51 = 1
			union all	select 51 as bettype,153 as sporttype, @auto_v153mpositiontaking_51 as autopositiontaking, @isauto_v153mpositiontaking_51 as isautopositiontaking WHERE @UpdatePositiontakingv153_51 = 1
			union all	select 52 as bettype,153 as sporttype, @auto_v153mpositiontaking_52 as autopositiontaking, @isauto_v153mpositiontaking_52 as isautopositiontaking WHERE @UpdatePositiontakingv153_51 = 1
		) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
where cs.custid = @custid 
if @@Error <> 0
BEGIN
	
	SELECT @ErrMsg = @UserName + ': '+ 
		case @Language 
			when 'E' then 'Error updating auto position taking'
			ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
		end	
		,  @ErrCode=205
	return
END

---------------------------------
--20131105@Johnson: Apply execrep when update pt on members
EXEC dbo.Acc_CustSetting3rd_05
	@mrecommend = @mrecommend,
	@recommend = @custid,
	@roleid = 2,
	@mode = 'horse',
	
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
	
	@old_auto_v151mpositiontaking_31 = @old_auto_v151mpositiontaking_31,
	@old_auto_v151mpositiontaking_32 = @old_auto_v151mpositiontaking_32,
	@old_auto_v151mpositiontaking_41 = @old_auto_v151mpositiontaking_41,
	@old_auto_v151mpositiontaking_42 = @old_auto_v151mpositiontaking_42,
	@old_auto_v151mpositiontaking_51 = @old_auto_v151mpositiontaking_51,
	@old_auto_v151mpositiontaking_52 = @old_auto_v151mpositiontaking_52,
	@old_auto_v152mpositiontaking_41 = @old_auto_v152mpositiontaking_41,
	@old_auto_v152mpositiontaking_42 = @old_auto_v152mpositiontaking_42,
	@old_auto_v152mpositiontaking_51 = @old_auto_v152mpositiontaking_51,
	@old_auto_v152mpositiontaking_52 = @old_auto_v152mpositiontaking_52,
	@old_auto_v153mpositiontaking_51 = @old_auto_v153mpositiontaking_51,
	@old_auto_v153mpositiontaking_52 = @old_auto_v153mpositiontaking_52,
	
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
	
	@old_isauto_v151mpositiontaking_31 = @old_isauto_v151mpositiontaking_31,
	@old_isauto_v151mpositiontaking_32 = @old_isauto_v151mpositiontaking_32,
	@old_isauto_v151mpositiontaking_41 = @old_isauto_v151mpositiontaking_41,
	@old_isauto_v151mpositiontaking_42 = @old_isauto_v151mpositiontaking_42,
	@old_isauto_v151mpositiontaking_51 = @old_isauto_v151mpositiontaking_51,
	@old_isauto_v151mpositiontaking_52 = @old_isauto_v151mpositiontaking_52,
	@old_isauto_v152mpositiontaking_41 = @old_isauto_v152mpositiontaking_41,
	@old_isauto_v152mpositiontaking_42 = @old_isauto_v152mpositiontaking_42,
	@old_isauto_v152mpositiontaking_51 = @old_isauto_v152mpositiontaking_51,
	@old_isauto_v152mpositiontaking_52 = @old_isauto_v152mpositiontaking_52,
	@old_isauto_v153mpositiontaking_51 = @old_isauto_v153mpositiontaking_51,
	@old_isauto_v153mpositiontaking_52 = @old_isauto_v153mpositiontaking_52,
	
	@UpdatePositiontakingv151_31 = @UpdatePositiontakingv151_31,
	@UpdatePositiontakingv151_41 = @UpdatePositiontakingv151_41,
	@UpdatePositiontakingv151_51 = @UpdatePositiontakingv151_51,
	@UpdatePositiontakingv152_41 = @UpdatePositiontakingv152_41,
	@UpdatePositiontakingv152_51 = @UpdatePositiontakingv152_51,
	@UpdatePositiontakingv153_51 = @UpdatePositiontakingv153_51,
	@IsCopyPreset151_31 = @IsCopyPreset151_31,
	@IsCopyPreset151_41 = @IsCopyPreset151_41,
	@IsCopyPreset151_51 = @IsCopyPreset151_51,
	@IsCopyPreset152_41 = @IsCopyPreset152_41,
	@IsCopyPreset152_51 = @IsCopyPreset152_51,
	@IsCopyPreset153_51 = @IsCopyPreset153_51,
	
	@updateallmembers = @updateallmembers,
	@updatemultiple = @updatemultiple,
	@newmpositiontaking = @newmpositiontaking
	
/*
if (@UpdateMultiple = 0 or @UpdatePositiontakingv151_31 = 1 or @UpdatePositiontakingv151_41 = 1 or @UpdatePositiontakingv151_51 = 1)
BEGIN --@UpdatePositiontakingv151 
	if (@auto_v151mpositiontaking_31 <> @old_auto_v151mpositiontaking_31 or @isauto_v151mpositiontaking_31 <> @old_isauto_v151mpositiontaking_31 ) and @UpdatePositiontakingv151_31 = 1
	BEGIN
		if @isauto_v151mpositiontaking_31 >0 --Use AUTO MPT
		BEGIN
			--m1=min(m3-a1,u2)
			select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=151 and bettype = 31
			update cs 
				set mpositiontaking = case when @maxpos - apositiontaking>@auto_v151mpositiontaking_31 then @auto_v151mpositiontaking_31 else @maxpos -apositiontaking end
			from CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
			inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
			where c.recommend = @custid and c.roleid = 1 and cs.bettype = 31 and cs.sporttype=151
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=219
				return
			END
		END
		else if @isauto_v151mpositiontaking_31 <> @old_isauto_v151mpositiontaking_31 --Not use AUTO MPT
		BEGIN
			if @updateallmembers = 1 --all member
			BEGIN
				--m1=min(m2,@newmpositiontaking)
				update cs 
					set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
				from CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = @custid and cs.sporttype=acs.sporttype and cs.bettype=acs.bettype
				where c.recommend = @custid and c.roleid = 1 and cs.bettype = 31 and cs.sporttype=151
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=220
					return
				END
			END
		END
	END	

	---------------------------------
	if (@auto_v151mpositiontaking_32 <> @old_auto_v151mpositiontaking_32 or @isauto_v151mpositiontaking_32 <> @old_isauto_v151mpositiontaking_32 ) and @UpdatePositiontakingv151_31 = 1
	BEGIN
		if @isauto_v151mpositiontaking_32 >0 --Use AUTO MPT
		BEGIN
			--m1=min(m3-a1,um2)
			select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=151 and bettype = 32
			update cs 
				set mpositiontaking = case when @maxpos - apositiontaking>@auto_v151mpositiontaking_32 then @auto_v151mpositiontaking_32 else @maxpos -apositiontaking end
			from CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
			inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
			where c.recommend = @custid and c.roleid = 1 and cs.bettype = 32 and cs.sporttype=151
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=219
				return
			END
		END
		else if @isauto_v151mpositiontaking_32 <> @old_isauto_v151mpositiontaking_32 --Not use AUTO MPT
		BEGIN
			if @updateallmembers = 1 --all member
			BEGIN
				--m1=min(m2,@newmpositiontaking)
				update cs 
					set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
				from CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = @custid and cs.sporttype=acs.sporttype and cs.bettype=acs.bettype
				where c.recommend = @custid and c.roleid = 1 and cs.bettype = 32 and cs.sporttype=151
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=220
					return
				END
			END
		END
	END

	---------------------------------
	if (@auto_v151mpositiontaking_41 <> @old_auto_v151mpositiontaking_41 or @isauto_v151mpositiontaking_41 <> @old_isauto_v151mpositiontaking_41 ) and @UpdatePositiontakingv151_41 = 1
	BEGIN
		if @isauto_v151mpositiontaking_41 >0 --Use AUTO MPT
		BEGIN
			--m1=min(m3-a1,um2)
			select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=151 and bettype = 41
			update cs 
				set mpositiontaking = case when @maxpos - apositiontaking>@auto_v151mpositiontaking_41 then @auto_v151mpositiontaking_41 else @maxpos -apositiontaking end
			from CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
			inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
			where c.recommend = @custid and c.roleid = 1 and cs.bettype = 41 and cs.sporttype=151
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=219
				return
			END
		END
		else if @isauto_v151mpositiontaking_41 <> @old_isauto_v151mpositiontaking_41 --Not use AUTO MPT
		BEGIN
			if @updateallmembers = 1 --all member
			BEGIN
				--m1=min(m2,@newmpositiontaking)
				update cs  
				set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
				from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = @custid and cs.sporttype=acs.sporttype and cs.bettype=acs.bettype
				where c.recommend = @custid and c.roleid = 1 and cs.bettype = 41 and cs.sporttype=151
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=220
					return
				END
			END
		END
	END

	---------------------------------
	if (@auto_v151mpositiontaking_42 <> @old_auto_v151mpositiontaking_42 or @isauto_v151mpositiontaking_42 <> @old_isauto_v151mpositiontaking_42 ) and @UpdatePositiontakingv151_41 = 1
	BEGIN
		if @isauto_v151mpositiontaking_42 >0 --Use AUTO MPT
		BEGIN
			--m1=min(m3-a1,um2)
			select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=151 and bettype = 42
			update cs 
				set mpositiontaking = case when @maxpos - apositiontaking>@auto_v151mpositiontaking_42 then @auto_v151mpositiontaking_42 else @maxpos -apositiontaking end
			from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
			inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
			where c.recommend = @custid and c.roleid = 1 and cs.bettype = 42 and cs.sporttype=151
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=219
				return
			END
		END
		else if @isauto_v151mpositiontaking_42 <> @old_isauto_v151mpositiontaking_42 --Not use AUTO MPT
		BEGIN
			if @updateallmembers = 1 --all member
			BEGIN
				--m1=min(m2,@newmpositiontaking)
				update cs
					set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
				from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = @custid and cs.sporttype=acs.sporttype and cs.bettype=acs.bettype
				where c.recommend = @custid and c.roleid = 1 and cs.bettype = 42 and cs.sporttype=151
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=220
					return
				END
			END
		END
	END
	------------------
	if (@auto_v151mpositiontaking_51 <> @old_auto_v151mpositiontaking_51 or @isauto_v151mpositiontaking_51 <> @old_isauto_v151mpositiontaking_51 ) and @UpdatePositiontakingv151_51 = 1
	BEGIN
		if @isauto_v151mpositiontaking_51 >0 --Use AUTO MPT
		BEGIN
			--m1=min(m3-a1,um2)
			select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=151 and bettype = 51
			update cs 
				set mpositiontaking = case when @maxpos - apositiontaking>@auto_v151mpositiontaking_51 then @auto_v151mpositiontaking_51 else @maxpos -apositiontaking end
			from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
			inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
			where c.recommend = @custid and c.roleid = 1 and cs.bettype = 51 and cs.sporttype=151
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=219
				return
			END
		END
		else if @isauto_v151mpositiontaking_51 <> @old_isauto_v151mpositiontaking_51 --Not use AUTO MPT
		BEGIN
			if @updateallmembers = 1 --all member
			BEGIN
				--m1=min(m2,@newmpositiontaking)
				update cs
					set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
				from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = @custid and cs.sporttype=acs.sporttype and cs.bettype=acs.bettype
				where c.recommend = @custid and c.roleid = 1 and cs.bettype = 51 and cs.sporttype=151
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=220
					return
				END
			END
		END
	END

	--------------------
	if (@auto_v151mpositiontaking_52 <> @old_auto_v151mpositiontaking_52 or @isauto_v151mpositiontaking_52 <> @old_isauto_v151mpositiontaking_52 ) and @UpdatePositiontakingv151_51 = 1
	BEGIN
		if @isauto_v151mpositiontaking_52 >0 --Use AUTO MPT
		BEGIN
			--m1=min(m3-a1,um2)
			select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=151 and bettype = 52
			update cs 
				set mpositiontaking = case when @maxpos - apositiontaking>@auto_v151mpositiontaking_52 then @auto_v151mpositiontaking_52 else @maxpos -apositiontaking end
			from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
			inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
			where c.recommend = @custid and c.roleid = 1 and cs.bettype = 52 and cs.sporttype=151
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=219
				return
			END
		END
		else if @isauto_v151mpositiontaking_52 <> @old_isauto_v151mpositiontaking_52 --Not use AUTO MPT
		BEGIN
			if @updateallmembers = 1 --all member
			BEGIN
				--m1=min(m2,@newmpositiontaking)
				update cs
					set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
				from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = @custid and cs.sporttype=acs.sporttype and cs.bettype=acs.bettype
				where c.recommend = @custid and c.roleid = 1 and cs.bettype = 52 and cs.sporttype=151
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=220
					return
				END
			END
		END
	END
	
	--Copy preset to member
	IF @IsCopyPreset151_31 = 1 
	BEGIN
		update cs
		set mpositiontaking = b.mpositiontaking
		from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
			inner join custinfo ci(nolock) on cs.custid = ci.custid and ci.recommend = @custid and ci.roleid = 1
			inner join 
				(
								select 151 as sporttype, 31 as bettype, @isauto_v151mpositiontaking_31 as isautopositiontaking, @old_isauto_v151mpositiontaking_31 as oldisautopositiontaking, @v151mpositiontaking_31 as mpositiontaking
					union all	select 151 as sporttype, 32 as bettype, @isauto_v151mpositiontaking_32 as isautopositiontaking, @old_isauto_v151mpositiontaking_32 as oldisautopositiontaking, @v151mpositiontaking_32 as mpositiontaking
				) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
		where b.isautopositiontaking = 0 and b.oldisautopositiontaking = 0  
	END
	IF @IsCopyPreset151_41 = 1 
	BEGIN
		update cs 
		set mpositiontaking = b.mpositiontaking
		from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
			inner join custinfo ci(nolock) on cs.custid = ci.custid and ci.recommend = @custid and ci.roleid = 1
			inner join 
				(
								select 151 as sporttype, 41 as bettype, @isauto_v151mpositiontaking_41 as isautopositiontaking, @old_isauto_v151mpositiontaking_41 as oldisautopositiontaking, @v151mpositiontaking_41 as mpositiontaking
					union all	select 151 as sporttype, 42 as bettype, @isauto_v151mpositiontaking_42 as isautopositiontaking, @old_isauto_v151mpositiontaking_42 as oldisautopositiontaking, @v151mpositiontaking_42 as mpositiontaking
				) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
		where b.isautopositiontaking = 0 and b.oldisautopositiontaking = 0  
	END

	IF @IsCopyPreset151_51 = 1 
	BEGIN
		update cs 
		set mpositiontaking = b.mpositiontaking
		from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
			inner join custinfo ci(nolock) on cs.custid = ci.custid and ci.recommend = @custid and ci.roleid = 1
			inner join 
				(
								select 151 as sporttype, 51 as bettype, @isauto_v151mpositiontaking_51 as isautopositiontaking, @old_isauto_v151mpositiontaking_51 as oldisautopositiontaking, @v151mpositiontaking_51 as mpositiontaking
					union all	select 151 as sporttype, 52 as bettype, @isauto_v151mpositiontaking_52 as isautopositiontaking, @old_isauto_v151mpositiontaking_52 as oldisautopositiontaking, @v151mpositiontaking_52 as mpositiontaking
				) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
		where b.isautopositiontaking = 0 and b.oldisautopositiontaking = 0  
	END
END--@UpdatePositiontakingv151 	
-----------------
if (@UpdateMultiple = 0 or @UpdatePositiontakingv152_41 = 1 or @UpdatePositiontakingv152_51 = 1)
BEGIN --@UpdatePositiontakingv152 
	if (@auto_v152mpositiontaking_41 <> @old_auto_v152mpositiontaking_41 or @isauto_v152mpositiontaking_41 <> @old_isauto_v152mpositiontaking_41 ) and @UpdatePositiontakingv152_41 = 1
	BEGIN
		if @isauto_v152mpositiontaking_41 >0 --Use AUTO MPT
		BEGIN
			--m1=min(m3-a1,um2)
			select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=152 and bettype = 41
			update cs 
				set mpositiontaking = case when @maxpos - apositiontaking>@auto_v152mpositiontaking_41 then @auto_v152mpositiontaking_41 else @maxpos -apositiontaking end
			from CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
			inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
			where c.recommend = @custid and c.roleid = 1 and cs.bettype = 41 and cs.sporttype=152
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=219
				return
			END
		END
		else if @isauto_v152mpositiontaking_41 <> @old_isauto_v152mpositiontaking_41 --Not use AUTO MPT
		BEGIN
			if @updateallmembers = 1 --all member
			BEGIN
				--m1=min(m2,@newmpositiontaking)
				update cs  
				set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
				from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = @custid and cs.sporttype=acs.sporttype and cs.bettype=acs.bettype
				where c.recommend = @custid and c.roleid = 1 and cs.bettype = 41 and cs.sporttype=152
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=220
					return
				END
			END
		END
	END
	----------------
	if (@auto_v152mpositiontaking_42 <> @old_auto_v152mpositiontaking_42 or @isauto_v152mpositiontaking_42 <> @old_isauto_v152mpositiontaking_42 ) and @UpdatePositiontakingv152_41 = 1
	BEGIN
		if @isauto_v152mpositiontaking_42 >0 --Use AUTO MPT
		BEGIN
			--m1=min(m3-a1,um2)
			select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=152 and bettype = 42
			update cs 
				set mpositiontaking = case when @maxpos - apositiontaking>@auto_v152mpositiontaking_42 then @auto_v152mpositiontaking_42 else @maxpos -apositiontaking end
			from CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
			inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
			where c.recommend = @custid and c.roleid = 1 and cs.bettype = 42 and cs.sporttype=152
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=219
				return
			END
		END
		else if @isauto_v152mpositiontaking_42 <> @old_isauto_v152mpositiontaking_42 --Not use AUTO MPT
		BEGIN
			if @updateallmembers = 1 --all member
			BEGIN
				--m1=min(m2,@newmpositiontaking)
				update cs  
				set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
				from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = @custid and cs.sporttype=acs.sporttype and cs.bettype=acs.bettype
				where c.recommend = @custid and c.roleid = 1 and cs.bettype = 42 and cs.sporttype=152
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=220
					return
				END
			END
		END
	END
	----------------------
	if (@auto_v152mpositiontaking_51 <> @old_auto_v152mpositiontaking_51 or @isauto_v152mpositiontaking_51 <> @old_isauto_v152mpositiontaking_51 ) and @UpdatePositiontakingv152_51 = 1
	BEGIN
		if @isauto_v152mpositiontaking_51 >0 --Use AUTO MPT
		BEGIN
			--m1=min(m3-a1,um2)
			select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=152 and bettype = 51
			update cs 
				set mpositiontaking = case when @maxpos - apositiontaking>@auto_v152mpositiontaking_51 then @auto_v152mpositiontaking_51 else @maxpos -apositiontaking end
			from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
			inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
			where c.recommend = @custid and c.roleid = 1 and cs.bettype = 51 and cs.sporttype=152
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=219
				return
			END
		END
		else if @isauto_v152mpositiontaking_51 <> @old_isauto_v152mpositiontaking_51 --Not use AUTO MPT
		BEGIN
			if @updateallmembers = 1 --all member
			BEGIN
				--m1=min(m2,@newmpositiontaking)
				update cs
					set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
				from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = @custid and cs.sporttype=acs.sporttype and cs.bettype=acs.bettype
				where c.recommend = @custid and c.roleid = 1 and cs.bettype = 51 and cs.sporttype=152
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=220
					return
				END
			END
		END
	END

	---------------
	if (@auto_v152mpositiontaking_52 <> @old_auto_v152mpositiontaking_52 or @isauto_v152mpositiontaking_52 <> @old_isauto_v152mpositiontaking_52 ) and @UpdatePositiontakingv152_51 = 1
	BEGIN
		if @isauto_v152mpositiontaking_52 >0 --Use AUTO MPT
		BEGIN
			--m1=min(m3-a1,um2)
			select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=152 and bettype = 52
			update cs 
				set mpositiontaking = case when @maxpos - apositiontaking>@auto_v152mpositiontaking_52 then @auto_v152mpositiontaking_52 else @maxpos -apositiontaking end
			from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
			inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
			where c.recommend = @custid and c.roleid = 1 and cs.bettype = 52 and cs.sporttype=152
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=219
				return
			END
		END
		else if @isauto_v152mpositiontaking_52 <> @old_isauto_v152mpositiontaking_52 --Not use AUTO MPT
		BEGIN
			if @updateallmembers = 1 --all member
			BEGIN
				--m1=min(m2,@newmpositiontaking)
				update cs
					set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
				from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = @custid and cs.sporttype=acs.sporttype and cs.bettype=acs.bettype
				where c.recommend = @custid and c.roleid = 1 and cs.bettype = 52 and cs.sporttype=152
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=220
					return
				END
			END
		END
	END
	
	--Copy preset to member
	IF @IsCopyPreset152_41 = 1 
	BEGIN
		update cs 
		set mpositiontaking = b.mpositiontaking
		from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
			inner join custinfo ci(nolock) on cs.custid = ci.custid and ci.recommend = @custid and ci.roleid = 1
			inner join 
				(
								select 152 as sporttype, 41 as bettype, @isauto_v152mpositiontaking_41 as isautopositiontaking, @old_isauto_v152mpositiontaking_41 as oldisautopositiontaking, @v152mpositiontaking_41 as mpositiontaking
					union all	select 152 as sporttype, 42 as bettype, @isauto_v152mpositiontaking_42 as isautopositiontaking, @old_isauto_v152mpositiontaking_42 as oldisautopositiontaking, @v152mpositiontaking_42 as mpositiontaking
				) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
		where b.isautopositiontaking = 0 and b.oldisautopositiontaking = 0  
	END

	IF @IsCopyPreset152_51 = 1 
	BEGIN
		update cs 
		set mpositiontaking = b.mpositiontaking
		from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
			inner join custinfo ci(nolock) on cs.custid = ci.custid and ci.recommend = @custid and ci.roleid = 1
			inner join 
				(
								select 152 as sporttype, 51 as bettype, @isauto_v152mpositiontaking_51 as isautopositiontaking, @old_isauto_v152mpositiontaking_51 as oldisautopositiontaking, @v152mpositiontaking_51 as mpositiontaking
					union all	select 152 as sporttype, 52 as bettype, @isauto_v152mpositiontaking_52 as isautopositiontaking, @old_isauto_v152mpositiontaking_52 as oldisautopositiontaking, @v152mpositiontaking_52 as mpositiontaking
				) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
		where b.isautopositiontaking = 0 and b.oldisautopositiontaking = 0  
	END
END --@UpdatePositiontakingv152
-----------------
if (@UpdateMultiple = 0 or @UpdatePositiontakingv153_51 = 1)
BEGIN --@UpdatePositiontakingv153
	if (@auto_v153mpositiontaking_51 <> @old_auto_v153mpositiontaking_51 or @isauto_v153mpositiontaking_51 <> @old_isauto_v153mpositiontaking_51 ) 
	BEGIN
		if @isauto_v153mpositiontaking_51 >0 --Use AUTO MPT
		BEGIN
			--m1=min(m3-a1,um2)
			select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=153 and bettype = 51
			update cs 
				set mpositiontaking = case when @maxpos - apositiontaking>@auto_v153mpositiontaking_51 then @auto_v153mpositiontaking_51 else @maxpos -apositiontaking end
			from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
			inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
			where c.recommend = @custid and c.roleid = 1 and cs.bettype = 51 and cs.sporttype=153
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=219
				return
			END
		END
		else if @isauto_v153mpositiontaking_51 <> @old_isauto_v153mpositiontaking_51 --Not use AUTO MPT
		BEGIN
			if @updateallmembers = 1 --all member
			BEGIN
				--m1=min(m2,@newmpositiontaking)
				update cs
					set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
				from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = @custid and cs.sporttype=acs.sporttype and cs.bettype=acs.bettype
				where c.recommend = @custid and c.roleid = 1 and cs.bettype = 51 and cs.sporttype=153
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=220
					return
				END
			END
		END
	END
	----------------------
	if (@auto_v153mpositiontaking_52 <> @old_auto_v153mpositiontaking_52 or @isauto_v153mpositiontaking_52 <> @old_isauto_v153mpositiontaking_52 ) and @UpdatePositiontakingv153_51 = 1
	BEGIN
		if @isauto_v153mpositiontaking_52 >0 --Use AUTO MPT
		BEGIN
			--m1=min(m3-a1,um2)
			select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=153 and bettype = 52
			update cs 
				set mpositiontaking = case when @maxpos - apositiontaking>@auto_v153mpositiontaking_52 then @auto_v153mpositiontaking_52 else @maxpos -apositiontaking end
			from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
			inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
			where c.recommend = @custid and c.roleid = 1 and cs.bettype = 52 and cs.sporttype=153
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=219
				return
			END
		END
		else if @isauto_v153mpositiontaking_52 <> @old_isauto_v153mpositiontaking_52 --Not use AUTO MPT
		BEGIN
			if @updateallmembers = 1 --all member
			BEGIN
				--m1=min(m2,@newmpositiontaking)
				update cs
					set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
				from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
				inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = @custid and cs.sporttype=acs.sporttype and cs.bettype=acs.bettype
				where c.recommend = @custid and c.roleid = 1 and cs.bettype = 52 and cs.sporttype=153
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  @UserName + ': '+
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
						,  @ErrCode=220
					return
				END
			END
		END
	END
	--Copy preset to member
	IF @IsCopyPreset153_51 = 1 
	BEGIN
		update cs 
		set mpositiontaking = b.mpositiontaking
		from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
			inner join custinfo ci(nolock) on cs.custid = ci.custid and ci.recommend = @custid and ci.roleid = 1
			inner join 
				(
								select 153 as sporttype, 51 as bettype, @isauto_v153mpositiontaking_51 as isautopositiontaking, @old_isauto_v153mpositiontaking_51 as oldisautopositiontaking, @v153mpositiontaking_51 as mpositiontaking
					union all	select 153 as sporttype, 52 as bettype, @isauto_v153mpositiontaking_52 as isautopositiontaking, @old_isauto_v153mpositiontaking_52 as oldisautopositiontaking, @v153mpositiontaking_52 as mpositiontaking
				) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
		where b.isautopositiontaking = 0 and b.oldisautopositiontaking = 0  
	END

END --@UpdatePositiontakingv153 
*/

EXEC dbo.Acc_CustSetting3rd_07 @recommend = @custid, @roleid = 2, @mode= 'horse'

/*	
EXEC dbo.Acc_CustomerUpdAgentHR_MaxPositiontaking @recommend = @custid
*/
if (@@error <> 0)
begin
	
	Select @ErrMsg = @UserName + ': '+
					case @Language 
						when 'E' then 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end, @ErrCode = 124					 
	
	return
end

Declare @LogSPData varchar(MAX),
		@TrackingValueDB VARCHAR(4000)

Select @LogSPData ='<Acc_CustomerUpdAgentHR_PositionTaking><info SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IsCopyPreset_31="'+ coalesce(cast(@IsCopyPreset151_31 as varchar(50)),space(1)) + '" ' +
'IsCopyPreset_41="'+ coalesce(cast(@IsCopyPreset151_41 as varchar(50)),space(1)) + '" ' +
'IsCopyPreset151_51="'+ coalesce(cast(@IsCopyPreset151_51 as varchar(50)),space(1)) + '" ' +
'IsCopyPreset152_41="'+ coalesce(cast(@IsCopyPreset152_41 as varchar(50)),space(1)) + '" ' +
'IsCopyPreset152_51="'+ coalesce(cast(@IsCopyPreset152_51 as varchar(50)),space(1)) + '" ' +
'IsCopyPreset153_51="'+ coalesce(cast(@IsCopyPreset153_51 as varchar(50)),space(1)) + '" ' +
'Updallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
'newmpt="'+ coalesce(cast(@newmpositiontaking as varchar(50)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

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
'v151apt_42="'+ coalesce(cast(@v151apositiontaking_42 as varchar(50)),space(1)) + '" '  +
'v151apt_51="'+ coalesce(cast(@v151apositiontaking_51 as varchar(50)),space(1)) + '" '  +
'v151apt_52="'+ coalesce(cast(@v151apositiontaking_52 as varchar(50)),space(1)) + '" '  +
'v152apt_41="'+ coalesce(cast(@v152apositiontaking_41 as varchar(50)),space(1)) + '" '  +
'v152apt_42="'+ coalesce(cast(@v152apositiontaking_42 as varchar(50)),space(1)) + '" '  +
'v152apt_51="'+ coalesce(cast(@v152apositiontaking_51 as varchar(50)),space(1)) + '" '  +
'v152apt_52="'+ coalesce(cast(@v152apositiontaking_52 as varchar(50)),space(1)) + '" '  +
'v153apt_51="'+ coalesce(cast(@v153apositiontaking_51 as varchar(50)),space(1)) + '" '  +
'v153apt_52="'+ coalesce(cast(@v153apositiontaking_52 as varchar(50)),space(1)) + '" '  
+ '/>' +

'<m v151mpt_31="'+ coalesce(cast(@v151mpositiontaking_31 as varchar(50)),space(1)) + '" ' +
'v151mpt_32="'+ coalesce(cast(@v151mpositiontaking_32 as varchar(50)),space(1)) + '" ' +
'v151mpt_41="'+ coalesce(cast(@v151mpositiontaking_41 as varchar(50)),space(1)) + '" ' +
'v151mpt_42="'+ coalesce(cast(@v151mpositiontaking_42 as varchar(50)),space(1)) + '" ' +
'v151mpt_51="'+ coalesce(cast(@v151mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
'v151mpt_52="'+ coalesce(cast(@v151mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
'v152mpt_41="'+ coalesce(cast(@v152mpositiontaking_41 as varchar(50)),space(1)) + '" '  +
'v152mpt_42="'+ coalesce(cast(@v152mpositiontaking_42 as varchar(50)),space(1)) + '" '  +
'v152mpt_51="'+ coalesce(cast(@v152mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
'v152mpt_52="'+ coalesce(cast(@v152mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
'v153mpt_51="'+ coalesce(cast(@v153mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
'v153mpt_52="'+ coalesce(cast(@v153mpositiontaking_52 as varchar(50)),space(1)) + '" '  
+ '/>' +

'<aum a_v151mpt_31="'+ coalesce(cast(@auto_v151mpositiontaking_31 as varchar(50)),space(1)) + '" ' +
'a_v151mpt_32="'+ coalesce(cast(@auto_v151mpositiontaking_32 as varchar(50)),space(1)) + '" ' +
'a_v151mpt_41="'+ coalesce(cast(@auto_v151mpositiontaking_41 as varchar(50)),space(1)) + '" ' +
'a_v151mpt_42="'+ coalesce(cast(@auto_v151mpositiontaking_42 as varchar(50)),space(1)) + '" ' +
'a_v151mpt_51="'+ coalesce(cast(@auto_v151mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
'a_v151mpt_52="'+ coalesce(cast(@auto_v151mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
'a_v152mpt_41="'+ coalesce(cast(@auto_v152mpositiontaking_41 as varchar(50)),space(1)) + '" '  +
'a_v152mpt_42="'+ coalesce(cast(@auto_v152mpositiontaking_42 as varchar(50)),space(1)) + '" '  +
'a_v152mpt_51="'+ coalesce(cast(@auto_v152mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
'a_v152mpt_52="'+ coalesce(cast(@auto_v152mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
'a_v153mpt_51="'+ coalesce(cast(@auto_v153mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
'a_v153mpt_52="'+ coalesce(cast(@auto_v153mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
'/>' +

'<iam isa_v151mpt_31="'+ coalesce(cast(@isauto_v151mpositiontaking_31 as varchar(50)),space(1)) + '" ' +
'isa_v151mpt_32="'+ coalesce(cast(@isauto_v151mpositiontaking_32 as varchar(50)),space(1)) + '" ' +
'isa_v151mpt_41="'+ coalesce(cast(@isauto_v151mpositiontaking_41 as varchar(50)),space(1)) + '" ' +
'isa_v151mpt_42="'+ coalesce(cast(@isauto_v151mpositiontaking_42 as varchar(50)),space(1)) + '" ' + 
'isa_v151mpt_51="'+ coalesce(cast(@isauto_v151mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
'isa_v151mpt_52="'+ coalesce(cast(@isauto_v151mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
'isa_v152mpt_41="'+ coalesce(cast(@isauto_v152mpositiontaking_41 as varchar(50)),space(1)) + '" '  +
'isa_v152mpt_42="'+ coalesce(cast(@isauto_v152mpositiontaking_42 as varchar(50)),space(1)) + '" '  +
'isa_v152mpt_51="'+ coalesce(cast(@isauto_v152mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
'isa_v152mpt_52="'+ coalesce(cast(@isauto_v152mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
'isa_v153mpt_51="'+ coalesce(cast(@isauto_v153mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
'isa_v153mpt_52="'+ coalesce(cast(@isauto_v153mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
'/></Acc_CustomerUpdAgentHR_PositionTaking>'

Select @TrackingValueDB ='<Acc_CustomerUpdAgentHR_PositionTaking><info SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IsCopyPreset_31="'+ coalesce(cast(@IsCopyPreset151_31 as varchar(50)),space(1)) + '" ' +
'IsCopyPreset_41="'+ coalesce(cast(@IsCopyPreset151_41 as varchar(50)),space(1)) + '" ' +
'IsCopyPreset151_51="'+ coalesce(cast(@IsCopyPreset151_51 as varchar(50)),space(1)) + '" ' +
'IsCopyPreset152_41="'+ coalesce(cast(@IsCopyPreset152_41 as varchar(50)),space(1)) + '" ' +
'IsCopyPreset152_51="'+ coalesce(cast(@IsCopyPreset152_51 as varchar(50)),space(1)) + '" ' +
'IsCopyPreset153_51="'+ coalesce(cast(@IsCopyPreset153_51 as varchar(50)),space(1)) + '" ' +
'Updallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
'newmpt="'+ coalesce(cast(@newmpositiontaking as varchar(50)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

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
'v151apt_42="'+ coalesce(cast(@old_v151apositiontaking_42 as varchar(50)),space(1)) + '" '  +
'v151apt_51="'+ coalesce(cast(@old_v151apositiontaking_51 as varchar(50)),space(1)) + '" '  +
'v151apt_52="'+ coalesce(cast(@old_v151apositiontaking_52 as varchar(50)),space(1)) + '" '  +
'v152apt_41="'+ coalesce(cast(@old_v152apositiontaking_41 as varchar(50)),space(1)) + '" '  +
'v152apt_42="'+ coalesce(cast(@old_v152apositiontaking_42 as varchar(50)),space(1)) + '" '  +
'v152apt_51="'+ coalesce(cast(@old_v152apositiontaking_51 as varchar(50)),space(1)) + '" '  +
'v152apt_52="'+ coalesce(cast(@old_v152apositiontaking_52 as varchar(50)),space(1)) + '" '  +
'v153apt_51="'+ coalesce(cast(@old_v153apositiontaking_51 as varchar(50)),space(1)) + '" '  +
'v153apt_52="'+ coalesce(cast(@old_v153apositiontaking_52 as varchar(50)),space(1)) + '" '  
+ '/>' +

'<m v151mpt_31="'+ coalesce(cast(@old_v151mpositiontaking_31 as varchar(50)),space(1)) + '" ' +
'v151mpt_32="'+ coalesce(cast(@old_v151mpositiontaking_32 as varchar(50)),space(1)) + '" ' +
'v151mpt_41="'+ coalesce(cast(@old_v151mpositiontaking_41 as varchar(50)),space(1)) + '" ' +
'v151mpt_42="'+ coalesce(cast(@old_v151mpositiontaking_42 as varchar(50)),space(1)) + '" ' +
'v151mpt_51="'+ coalesce(cast(@old_v151mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
'v151mpt_52="'+ coalesce(cast(@old_v151mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
'v152mpt_41="'+ coalesce(cast(@old_v152mpositiontaking_41 as varchar(50)),space(1)) + '" '  +
'v152mpt_42="'+ coalesce(cast(@old_v152mpositiontaking_42 as varchar(50)),space(1)) + '" '  +
'v152mpt_51="'+ coalesce(cast(@old_v152mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
'v152mpt_52="'+ coalesce(cast(@old_v152mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
'v153mpt_51="'+ coalesce(cast(@old_v153mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
'v153mpt_52="'+ coalesce(cast(@old_v153mpositiontaking_52 as varchar(50)),space(1)) + '" '  
+ '/>' +

'<aum a_v151mpt_31="'+ coalesce(cast(@old_auto_v151mpositiontaking_31 as varchar(50)),space(1)) + '" ' +
'a_v151mpt_32="'+ coalesce(cast(@old_auto_v151mpositiontaking_32 as varchar(50)),space(1)) + '" ' +
'a_v151mpt_41="'+ coalesce(cast(@old_auto_v151mpositiontaking_41 as varchar(50)),space(1)) + '" ' +
'a_v151mpt_42="'+ coalesce(cast(@old_auto_v151mpositiontaking_42 as varchar(50)),space(1)) + '" ' +
'a_v151mpt_51="'+ coalesce(cast(@old_auto_v151mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
'a_v151mpt_52="'+ coalesce(cast(@old_auto_v151mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
'a_v152mpt_41="'+ coalesce(cast(@old_auto_v152mpositiontaking_41 as varchar(50)),space(1)) + '" '  +
'a_v152mpt_42="'+ coalesce(cast(@old_auto_v152mpositiontaking_42 as varchar(50)),space(1)) + '" '  +
'a_v152mpt_51="'+ coalesce(cast(@old_auto_v152mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
'a_v152mpt_52="'+ coalesce(cast(@old_auto_v152mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
'a_v153mpt_51="'+ coalesce(cast(@old_auto_v153mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
'a_v153mpt_52="'+ coalesce(cast(@old_auto_v153mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
'/>' +

'<iam isa_v151mpt_31="'+ coalesce(cast(@old_isauto_v151mpositiontaking_31 as varchar(50)),space(1)) + '" ' +
'isa_v151mpt_32="'+ coalesce(cast(@old_isauto_v151mpositiontaking_32 as varchar(50)),space(1)) + '" ' +
'isa_v151mpt_41="'+ coalesce(cast(@old_isauto_v151mpositiontaking_41 as varchar(50)),space(1)) + '" ' +
'isa_v151mpt_42="'+ coalesce(cast(@old_isauto_v151mpositiontaking_42 as varchar(50)),space(1)) + '" ' + 
'isa_v151mpt_51="'+ coalesce(cast(@old_isauto_v151mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
'isa_v151mpt_52="'+ coalesce(cast(@old_isauto_v151mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
'isa_v152mpt_41="'+ coalesce(cast(@old_isauto_v152mpositiontaking_41 as varchar(50)),space(1)) + '" '  +
'isa_v152mpt_42="'+ coalesce(cast(@old_isauto_v152mpositiontaking_42 as varchar(50)),space(1)) + '" '  +
'isa_v152mpt_51="'+ coalesce(cast(@old_isauto_v152mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
'isa_v152mpt_52="'+ coalesce(cast(@old_isauto_v152mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
'isa_v153mpt_51="'+ coalesce(cast(@old_isauto_v153mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
'isa_v153mpt_52="'+ coalesce(cast(@old_isauto_v153mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
'/></Acc_CustomerUpdAgentHR_PositionTaking>'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

--Log positiontaking
BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 420,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END TRY
BEGIN CATCH		
	Select @LogSPData ='<Acc_CustomerUpdAgentHR_PositionTaking><info SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IsCopyPreset_31="'+ coalesce(cast(@IsCopyPreset151_31 as varchar(50)),space(1)) + '" ' +
	'IsCopyPreset_41="'+ coalesce(cast(@IsCopyPreset151_41 as varchar(50)),space(1)) + '" ' +
	'IsCopyPreset151_51="'+ coalesce(cast(@IsCopyPreset151_51 as varchar(50)),space(1)) + '" ' +
	'IsCopyPreset152_41="'+ coalesce(cast(@IsCopyPreset152_41 as varchar(50)),space(1)) + '" ' +
	'IsCopyPreset152_51="'+ coalesce(cast(@IsCopyPreset152_51 as varchar(50)),space(1)) + '" ' +
	'IsCopyPreset153_51="'+ coalesce(cast(@IsCopyPreset153_51 as varchar(50)),space(1)) + '" ' +
	'Updallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
	'newmpt="'+ coalesce(cast(@newmpositiontaking as varchar(50)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
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
	'v151apt_42="'+ coalesce(cast(@v151apositiontaking_42 as varchar(50)),space(1)) + '" '  +
	'v151apt_51="'+ coalesce(cast(@v151apositiontaking_51 as varchar(50)),space(1)) + '" '  +
	'v151apt_52="'+ coalesce(cast(@v151apositiontaking_52 as varchar(50)),space(1)) + '" '  +
	'v152apt_41="'+ coalesce(cast(@v152apositiontaking_41 as varchar(50)),space(1)) + '" '  +
	'v152apt_42="'+ coalesce(cast(@v152apositiontaking_42 as varchar(50)),space(1)) + '" '  +
	'v152apt_51="'+ coalesce(cast(@v152apositiontaking_51 as varchar(50)),space(1)) + '" '  +
	'v152apt_52="'+ coalesce(cast(@v152apositiontaking_52 as varchar(50)),space(1)) + '" '  +
	'v153apt_51="'+ coalesce(cast(@v153apositiontaking_51 as varchar(50)),space(1)) + '" '  +
	'v153apt_52="'+ coalesce(cast(@v153apositiontaking_52 as varchar(50)),space(1)) + '" '  
	+ '/>' +

	'<m v151mpt_31="'+ coalesce(cast(@v151mpositiontaking_31 as varchar(50)),space(1)) + '" ' +
	'v151mpt_32="'+ coalesce(cast(@v151mpositiontaking_32 as varchar(50)),space(1)) + '" ' +
	'v151mpt_41="'+ coalesce(cast(@v151mpositiontaking_41 as varchar(50)),space(1)) + '" ' +
	'v151mpt_42="'+ coalesce(cast(@v151mpositiontaking_42 as varchar(50)),space(1)) + '" ' +
	'v151mpt_51="'+ coalesce(cast(@v151mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
	'v151mpt_52="'+ coalesce(cast(@v151mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
	'v152mpt_41="'+ coalesce(cast(@v152mpositiontaking_41 as varchar(50)),space(1)) + '" '  +
	'v152mpt_42="'+ coalesce(cast(@v152mpositiontaking_42 as varchar(50)),space(1)) + '" '  +
	'v152mpt_51="'+ coalesce(cast(@v152mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
	'v152mpt_52="'+ coalesce(cast(@v152mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
	'v153mpt_51="'+ coalesce(cast(@v153mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
	'v153mpt_52="'+ coalesce(cast(@v153mpositiontaking_52 as varchar(50)),space(1)) + '" '  
	+ '/>' +

	'<aum a_v151mpt_31="'+ coalesce(cast(@auto_v151mpositiontaking_31 as varchar(50)),space(1)) + '" ' +
	'a_v151mpt_32="'+ coalesce(cast(@auto_v151mpositiontaking_32 as varchar(50)),space(1)) + '" ' +
	'a_v151mpt_41="'+ coalesce(cast(@auto_v151mpositiontaking_41 as varchar(50)),space(1)) + '" ' +
	'a_v151mpt_42="'+ coalesce(cast(@auto_v151mpositiontaking_42 as varchar(50)),space(1)) + '" ' +
	'a_v151mpt_51="'+ coalesce(cast(@auto_v151mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
	'a_v151mpt_52="'+ coalesce(cast(@auto_v151mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
	'a_v152mpt_41="'+ coalesce(cast(@auto_v152mpositiontaking_41 as varchar(50)),space(1)) + '" '  +
	'a_v152mpt_42="'+ coalesce(cast(@auto_v152mpositiontaking_42 as varchar(50)),space(1)) + '" '  +
	'a_v152mpt_51="'+ coalesce(cast(@auto_v152mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
	'a_v152mpt_52="'+ coalesce(cast(@auto_v152mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
	'a_v153mpt_51="'+ coalesce(cast(@auto_v153mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
	'a_v153mpt_52="'+ coalesce(cast(@auto_v153mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
	'/>' +

	'<iam isa_v151mpt_31="'+ coalesce(cast(@isauto_v151mpositiontaking_31 as varchar(50)),space(1)) + '" ' +
	'isa_v151mpt_32="'+ coalesce(cast(@isauto_v151mpositiontaking_32 as varchar(50)),space(1)) + '" ' +
	'isa_v151mpt_41="'+ coalesce(cast(@isauto_v151mpositiontaking_41 as varchar(50)),space(1)) + '" ' +
	'isa_v151mpt_42="'+ coalesce(cast(@isauto_v151mpositiontaking_42 as varchar(50)),space(1)) + '" ' + 
	'isa_v151mpt_51="'+ coalesce(cast(@isauto_v151mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
	'isa_v151mpt_52="'+ coalesce(cast(@isauto_v151mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
	'isa_v152mpt_41="'+ coalesce(cast(@isauto_v152mpositiontaking_41 as varchar(50)),space(1)) + '" '  +
	'isa_v152mpt_42="'+ coalesce(cast(@isauto_v152mpositiontaking_42 as varchar(50)),space(1)) + '" '  +
	'isa_v152mpt_51="'+ coalesce(cast(@isauto_v152mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
	'isa_v152mpt_52="'+ coalesce(cast(@isauto_v152mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
	'isa_v153mpt_51="'+ coalesce(cast(@isauto_v153mpositiontaking_51 as varchar(50)),space(1)) + '" '  +
	'isa_v153mpt_52="'+ coalesce(cast(@isauto_v153mpositiontaking_52 as varchar(50)),space(1)) + '" '  +
	'/></Acc_CustomerUpdAgentHR_PositionTaking>'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 420,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END CATCH
	

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentHR_PositionTaking] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentHR_PositionTaking] TO [bodbDownlineNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgentHR_PositionTaking] TO [vnteam] AS [dbo]