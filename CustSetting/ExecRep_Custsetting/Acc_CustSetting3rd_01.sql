/*<info serverAlias="DBCUST-CustDB" executers="wsv_alp,wsv_nap,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE dbo.Acc_CustSetting3rd_01
AS
/*
	Created: 20090520@Phuc
	Task : Update member level when update l4(HR)
	DB: DBCUST/custDB
	Original: Acc_CustomerUpdSuperHR_MaxPositiontaking, Acc_CustomerUpdSuper_MaxPositiontaking, Acc_CustomerUpdSuperFI_MaxPositiontaking

	Revisions for Acc_CustomerUpdSuperHR_MaxPositiontaking:
		- 20090716@Phuc: Remove connection to custoveride table cause of l4=s4(correct data when s1+m1+a1>s4)
		- 20091201@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
		- 20110126@Lukas: add Greyhound & Harness racing game
		- 20111028@Thien: convert to ExecRep SP

	Revisions for Acc_CustomerUpdSuper_MaxPositiontaking:
		- 20080923@Phuc: Recal auto master postiontaking   
		- 20090716@Phuc: Remove connection to custoveride table cause of l4=s4(correct data when s1+m1+a1>s4)
		- 20100904@Henry: Add new sporttype (161: numbergame)
		- 20110728@Johnson: - remove bettype dead ball over/under of number game
							- add more bettype for nubmer game Warrior,  Next combo and Number Group
		- 20111028@Thien: convert to ExecRep SP
		- 20111029@Thien: merge Acc_CustomerUpdSuperHR_MaxPositiontaking, Acc_CustomerUpdSuperFI_MaxPositiontaking and Acc_CustomerUpdSuper_MinPositiontaking to put
							into execRep, for Horse racing and Number Game and finance
		- 20120803@Dan: add virtual soccer sport type
		- 20121203@Scott: add virtual tennis sport type
		- 20130222@Johnson: add virtual horse racing setting (sporttype: 181)
		- 20131126@Kathy: Add Virtual Greyhounds/Motor Racing (182, 184) [Redmine:#7234]
		- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]
		- 20150610@Daniel: 
			+ Improve medthod check table existing in subscribers	
			+ Separate custDB to new server DBCUST   	
		- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
		- 20190924@Elodie: 3rd party products - Remove Inactive Products Phase 2 [Redmine: #118699]
		- 20221123@Elodie: Clean code [Redmine: #179711]
	Param's Explanation: 
		• @mode:
			= 'number': Number Game
    
		• @ErrCode:
			= 0: Update successfully.
			> 0: Specific Error.
  
		• @ErrMsg: Error description.
*/
BEGIN
	RETURN	
END

