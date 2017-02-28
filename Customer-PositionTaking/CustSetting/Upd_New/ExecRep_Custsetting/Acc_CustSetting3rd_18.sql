USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustSetting3rd_18]    Script Date: 06/11/2015 06:21:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_18] 
	@maxcustid INT	
AS
/*
	Created: ??
	Date: 20150108
	Task : 
	DB: DBCUST/CustDB
	Original:

	Revisions:
	   - 20150610@Daniel: 
	      + Improve medthod check table existing in subscribers	
	      + Separate custDB to new server DBCUST  

	Param's Explanation:
		
*/ 
BEGIN
	SET NOCOUNT ON;
	
	if NOT(dbo.f_CheckRepTable('custinfo') = 1 
	     AND dbo.f_CheckRepTable('Dep_CustSuper') = 1 
	     AND dbo.f_CheckRepTable('CustGameType') = 1 
     )
	   	RETURN  		

	--- get customer dont have gametypeid in 11,13
	select gt.custid into #missedGametype
	from custInfo c with(nolock)
		inner join CustGameType gt with(nolock) on c.custid = gt.CustID 
	where c.srecommend in (select custid from Dep_CustSuper with(nolocK))
	and c.custid <= @maxcustid 
	group by gt.custid
	having COUNT(GameTypeID) <> 9

	-- get 2 bettypes to use as template for 11 and 13 ( always disabled = 1)
	create table #custgametype(custid int, gametypeid int, stakelevelList varchar(50) , maxPerGameType money, MinBet money, Maxbet money, isDisabled bit)
	insert into #custgametype
	select gt.custid, case when GameTypeID = 1 then 11 else 13 end gametypeid, gt.StakeLevelList, gt.MaxPerGameType, gt.MinBet, gt.MaxBet, 1
	from CustGameType gt with(nolock)
		inner join #missedGametype t on gt.CustID = t.CustID 
	where GameTypeID in (1,3)

	INSERT INTO CustGameType(CustID, GameTypeID, StakeLevelList, MaxPerGameType, MinBet, MaxBet, IsDisabled)
	SELECT t.CustID, t.GameTypeID, t.StakeLevelList, t.MaxPerGameType, t.MinBet, t.MaxBet, t.IsDisabled
	FROM #custgametype t
		LEFT JOIN  custgametype gt on t.custid = gt.custid and t.gametypeid = gt.GameTypeID
	WHERE gt.CustID IS NULL


END
