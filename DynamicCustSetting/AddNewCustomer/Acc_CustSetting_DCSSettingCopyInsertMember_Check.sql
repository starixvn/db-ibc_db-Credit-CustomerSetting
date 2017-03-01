ALTER PROCEDURE [dbo].[Acc_CustSetting_DCSSettingCopyInsertMember_Check] 
	@ExistingCustID	INT		
	, @ErrCode		INT	= 0	OUTPUT
AS
/*
	Created: 20151030@Elodie
	Task : Check settings of an existing member Into DCS Structure
	DB:  DBCUST/CustDB
	Original:

	Revision

	*/
BEGIN
	SET NOCOUNT ON

	DECLARE @SettingMode BIT, @AgentID INT
	--Get setting mode
	SELECT @SettingMode = IsGrouped
	FROM dbo.CustSettingMode3rd
	WHERE CustID= @ExistingCustID

	SELECT @AgentID = recommend FROM CustInfo WITH (NOLOCK) WHERE custid = @ExistingCustID

	IF @SettingMode = 0
	BEGIN
		--check a1<a2
		IF EXISTS (SELECT 1
					FROM dbo.CustPTSetting3rd_Member mcs WITH (NOLOCK)
						INNER JOIN dbo.CustPTSetting3rd_Agent acs WITH (NOLOCK) ON acs.sporttype = mcs.sporttype AND acs.bettype = mcs.bettype AND acs.islive = mcs.islive
					WHERE mcs.CustID = @ExistingCustID AND acs.custid = @AgentID AND mcs.agentPT > acs.agentPT)
			select @ErrCode = 101		
	END
	ELSE
	BEGIN		
		--check a1<a2
		IF EXISTS (SELECT 1
					FROM dbo.CustPTGroupSetting3rd_Member mcs WITH (NOLOCK)
						INNER JOIN dbo.CustPTSetting3rd_Agent acs WITH (NOLOCK) ON acs.sporttype = mcs.sporttype AND acs.bettype = mcs.bettype AND acs.islive = mcs.islive
					WHERE mcs.AgentID = @AgentID AND acs.custid = @AgentID AND mcs.agentPT > acs.agentPT)
			select @ErrCode = 102		
	END
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DCSSettingCopyInsertMember_Check] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting_DCSSettingCopyInsertMember_Check] TO [vnteam]