SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_DefaultMemberPTCorrect] 
	  @AgentID			INT
	, @MasterID			INT
	, @SuperID			INT
	, @CorrectedPT_XML	VARCHAR(MAX) OUTPUT
AS
/*
	Created: 20141105@Dominic
	Task : Correct default PT settings of a specific member
	DB:  DBCUST/CustDB
	Original:

	Param's Explanation:
	• @CustID: Member ID
	• @CorrectedPT_XML: Corrected PT setting of a member
					<ROOT>
							<PT 
									SportType="1" 
									BetType="1" 
									IsLive="1" 
									SuperPT="90" 
									MasterPT="90" 
									AgentPT="90" 
									IsAutoMPT="0" 
									AutoMPT="0"  
									IsAutoSPT="0" 
									AutoSPT="0"
							/>
					</ROOT>
	*/
BEGIN
	DECLARE @memberPTTbl TABLE (
		[SportType]		[smallint]	NOT NULL
		, [BetType]		[smallint]	NOT NULL
		, [Islive]		[bit]		NOT NULL
		, [SuperPT]		[tinyint]	NOT NULL
		, [MasterPT]	[tinyint]	NOT NULL
		, [AgentPT]		[tinyint]	NOT NULL
		, [IsAutoMPT]	[bit]		NOT NULL
		, [AutoMPT]		[tinyint]	NOT NULL
		, [IsAutoSPT]	[bit]		NOT NULL
		, [AutoSPT]		[tinyint]	NOT NULL
		)
	DECLARE @mpos	SMALLMONEY
		, @apos		SMALLMONEY
		, @spos		SMALLMONEY
		, @mapos1	SMALLMONEY
		, @mapos2	SMALLMONEY
		, @mapos	SMALLMONEY
		, @maxmapos SMALLMONEY

	--Get default PT settings	
	INSERT INTO @memberPTTbl (
		SportType
		, BetType
		, Islive
		, SuperPT
		, MasterPT
		, AgentPT
		, IsAutoMPT
		, AutoMPT
		, IsAutoSPT
		, AutoSPT
		)
	SELECT acs.SportType
		, acs.BetType
		, acs.IsLive
		, mcs.superPT
		, acs.masterPT
		, acs.agentPT
		, 0
		, 0
		, 0
		, 0
	FROM dbo.CustPTSetting3rd_Agent acs WITH (NOLOCK)
	INNER JOIN dbo.CustPTSetting3rd_Agent mcs WITH (NOLOCK)
		ON acs.sporttype = mcs.sporttype
			AND acs.bettype = mcs.bettype
			AND acs.islive = mcs.islive
			AND mcs.custid = @MasterID
	WHERE acs.custid = @AgentID


	--**ADJUST PT**--
	--if im1=1 or im2=1 then then m1=min(m4-a1,m3-a1, im1?um1:um2)
	UPDATE main
	SET main.MasterPT = CASE 
			WHEN spt.masterPT > mpt.masterPT
				THEN CASE 
						WHEN mpt.masterPT - main.AgentPT > (
								CASE 
									WHEN main.IsAutoMPT = 1
										THEN main.AutoMPT
									ELSE apt.AutoMasterPT
									END
								)
							THEN (
									CASE 
										WHEN main.IsAutoMPT = 1
											THEN main.AutoMPT
										ELSE apt.AutoMasterPT
										END
									)
						ELSE mpt.masterPT - main.AgentPT
						END
			ELSE CASE 
					WHEN spt.masterPT - main.AgentPT > (
							CASE 
								WHEN main.IsAutoMPT = 1
									THEN main.AutoMPT
								ELSE apt.AutoMasterPT
								END
							)
						THEN (
								CASE 
									WHEN main.IsAutoMPT = 1
										THEN main.AutoMPT
									ELSE apt.AutoMasterPT
									END
								)
					ELSE spt.masterPT - main.AgentPT
					END
			END
	FROM @memberPTTbl main
	INNER JOIN dbo.CustPTSetting3rd_Agent AS mpt WITH (NOLOCK)
		ON mpt.custid = @MasterID
			AND mpt.sporttype = main.sporttype
			AND mpt.bettype = main.bettype
			AND mpt.islive = main.Islive
	INNER JOIN dbo.CustPTSetting3rd_Agent AS spt WITH (NOLOCK)
		ON spt.custid = @SuperID
			AND spt.sporttype = main.sporttype
			AND spt.bettype = main.bettype
			AND spt.islive = main.Islive
	INNER JOIN dbo.CustPTSetting3rd_Agent AS apt WITH (NOLOCK)
		ON apt.custid = @AgentID
			AND apt.sporttype = main.sporttype
			AND apt.bettype = main.bettype
			AND apt.islive = main.Islive
	WHERE (
			apt.IsAutoMasterPT = 1
			OR main.IsAutoMPT = 1
			)
	--if is1 = 1 or is3=1 then s1=min(s4-m1-a1, is1?us1:us3)
	UPDATE main
	SET main.SuperPT = CASE 
			WHEN spt.superPT - main.masterPT - main.agentPT > (
					CASE 
						WHEN main.IsAutoSPT = 1
							THEN main.AutoSPT
						ELSE mpt.AutoSuperPT
						END
					)
				THEN (
						CASE 
							WHEN main.IsAutoSPT = 1
								THEN main.autoSPT
							ELSE mpt.AutoSuperPT
							END
						)
			ELSE spt.superPT - main.masterPT - main.agentPT
			END
	FROM @memberPTTbl main
	INNER JOIN dbo.CustPTSetting3rd_Agent AS mpt WITH (NOLOCK)
		ON mpt.custid = @MasterID
			AND mpt.sporttype = main.sporttype
			AND mpt.bettype = main.bettype
			AND mpt.islive = main.Islive
	INNER JOIN dbo.CustPTSetting3rd_Agent AS spt WITH (NOLOCK)
		ON spt.custid = @SuperID
			AND spt.sporttype = main.sporttype
			AND spt.bettype = main.bettype
			AND spt.islive = main.Islive
	WHERE (
			main.IsAutoSPT = 1
			OR mpt.IsAutoSuperPT = 1
			)
					
	--**CORRECT PT**--
	--if n2 > a1 then a1 = n2
	--if n2 > a1 then m1=min(m1, m3-n2)
	UPDATE main
	SET main.AgentPT = apt.minPT
		, main.MasterPT = CASE 
			WHEN main.MasterPT + apt.minPT > mpt.masterPT
				THEN mpt.masterPT - apt.minPT
			ELSE main.MasterPT
			END
	FROM @memberPTTbl main
	INNER JOIN dbo.CustPTSetting3rd_Agent AS mpt WITH (NOLOCK)
		ON mpt.custid = @MasterID
			AND mpt.sporttype = main.sporttype
			AND mpt.bettype = main.bettype
			AND mpt.islive = main.Islive
	INNER JOIN dbo.CustPTSetting3rd_Agent AS apt WITH (NOLOCK)
		ON apt.custid = @AgentID
			AND apt.sporttype = main.sporttype
			AND apt.bettype = main.bettype
			AND apt.islive = main.Islive
	WHERE main.AgentPT < apt.minPT

	--if a1 > l2 then a1 = l2
	UPDATE main
	SET main.AgentPT = apt.maxPT
	FROM @memberPTTbl main
	INNER JOIN dbo.CustPTSetting3rd_Agent AS apt WITH (NOLOCK)
		ON apt.custid = @AgentID
			AND apt.sporttype = main.sporttype
			AND apt.bettype = main.bettype
			AND apt.islive = main.Islive
	WHERE main.AgentPT > apt.maxPT

	--if im1=1 or im2=1 then then m1=min(m4-a1,m3-a1, im1?um1:um2)
	UPDATE main
	SET main.MasterPT = CASE 
			WHEN spt.masterPT > mpt.masterPT
				THEN CASE 
						WHEN mpt.masterPT - main.AgentPT > (
								CASE 
									WHEN main.IsAutoMPT = 1
										THEN main.AutoMPT
									ELSE apt.AutoMasterPT
									END
								)
							THEN (
									CASE 
										WHEN main.IsAutoMPT = 1
											THEN main.AutoMPT
										ELSE apt.AutoMasterPT
										END
									)
						ELSE mpt.masterPT - main.AgentPT
						END
			ELSE CASE 
					WHEN spt.masterPT - main.AgentPT > (
							CASE 
								WHEN main.IsAutoMPT = 1
									THEN main.AutoMPT
								ELSE apt.AutoMasterPT
								END
							)
						THEN (
								CASE 
									WHEN main.IsAutoMPT = 1
										THEN main.AutoMPT
									ELSE apt.AutoMasterPT
									END
								)
					ELSE spt.masterPT - main.AgentPT
					END
			END
	FROM @memberPTTbl main
	INNER JOIN dbo.CustPTSetting3rd_Agent AS mpt WITH (NOLOCK)
		ON mpt.custid = @MasterID
			AND mpt.sporttype = main.sporttype
			AND mpt.bettype = main.bettype
			AND mpt.islive = main.Islive
	INNER JOIN dbo.CustPTSetting3rd_Agent AS spt WITH (NOLOCK)
		ON spt.custid = @SuperID
			AND spt.sporttype = main.sporttype
			AND spt.bettype = main.bettype
			AND spt.islive = main.Islive
	INNER JOIN dbo.CustPTSetting3rd_Agent AS apt WITH (NOLOCK)
		ON apt.custid = @AgentID
			AND apt.sporttype = main.sporttype
			AND apt.bettype = main.bettype
			AND apt.islive = main.Islive
	WHERE (
			apt.IsAutoMasterPT = 1
			OR main.IsAutoMPT = 1
			)

	--m1 = max(m1,n3-a1)
	UPDATE main
	SET main.MasterPT = mpt.minPT - main.AgentPT
	FROM @memberPTTbl main
	INNER JOIN dbo.CustPTSetting3rd_Agent AS mpt WITH (NOLOCK)
		ON mpt.custid = @MasterID
			AND mpt.sporttype = main.sporttype
			AND mpt.bettype = main.bettype
			AND mpt.islive = main.Islive
	WHERE main.AgentPT + main.MasterPT < mpt.minPT

	--if a1 + m1 > l3 then	
	--@x=min(m3,l3)
	--@y= max(0,@x-a1)
	--m1=@y
	--@z=min(@x-@y,a1)
	--a1=max(@z,n2)
	UPDATE main
	SET @maxmapos = CASE 
			WHEN mpt.masterPT > mpt.maxPT
				THEN mpt.maxPT
			ELSE mpt.masterPT
			END
		, @mpos = CASE 
			WHEN @maxmapos - main.AgentPT < 0
				THEN 0
			ELSE @maxmapos - main.AgentPT
			END
		, main.MasterPT = @mpos
		, @apos = CASE 
			WHEN main.AgentPT + @mpos > @maxmapos
				THEN @maxmapos - @mpos
			ELSE main.AgentPT
			END
		, main.AgentPT = CASE 
			WHEN @apos < apt.minPT
				THEN apt.minPT
			ELSE @apos
			END
	FROM @memberPTTbl main
	INNER JOIN dbo.CustPTSetting3rd_Agent AS mpt WITH (NOLOCK)
		ON mpt.custid = @MasterID
			AND mpt.sporttype = main.sporttype
			AND mpt.bettype = main.bettype
			AND mpt.islive = main.Islive
	INNER JOIN dbo.CustPTSetting3rd_Agent AS apt WITH (NOLOCK)
		ON apt.custid = @AgentID
			AND apt.sporttype = main.sporttype
			AND apt.bettype = main.bettype
			AND apt.islive = main.Islive
	WHERE main.AgentPT + main.MasterPT > mpt.maxPT

	--if is1 = 1 or is3=1 then s1=min(s4-m1-a1, is1?us1:us3)
	UPDATE main
	SET main.SuperPT = CASE 
			WHEN spt.superPT - main.masterPT - main.agentPT > (
					CASE 
						WHEN main.IsAutoSPT = 1
							THEN main.AutoSPT
						ELSE mpt.AutoSuperPT
						END
					)
				THEN (
						CASE 
							WHEN main.IsAutoSPT = 1
								THEN main.autoSPT
							ELSE mpt.AutoSuperPT
							END
						)
			ELSE spt.superPT - main.masterPT - main.agentPT
			END
	FROM @memberPTTbl main
	INNER JOIN dbo.CustPTSetting3rd_Agent AS mpt WITH (NOLOCK)
		ON mpt.custid = @MasterID
			AND mpt.sporttype = main.sporttype
			AND mpt.bettype = main.bettype
			AND mpt.islive = main.Islive
	INNER JOIN dbo.CustPTSetting3rd_Agent AS spt WITH (NOLOCK)
		ON spt.custid = @SuperID
			AND spt.sporttype = main.sporttype
			AND spt.bettype = main.bettype
			AND spt.islive = main.Islive
	WHERE (
			main.IsAutoSPT = 1
			OR mpt.IsAutoSuperPT = 1
			)

	--s1=max(s1,n4-m1-a1)
	UPDATE main
	SET main.SuperPT = spt.minPT - main.masterPT - main.agentPT
	FROM @memberPTTbl main
	INNER JOIN dbo.CustPTSetting3rd_Agent AS spt WITH (NOLOCK)
		ON spt.custid = @SuperID
			AND spt.sporttype = main.sporttype
			AND spt.bettype = main.bettype
			AND spt.islive = main.Islive
	WHERE main.agentPT + main.masterPT + main.SuperPT < spt.minPT

	--if s1+m1+a1>s4	
	--@x=max(s4-m1-a1, 0)
	--s1=@x
	--@y=min(s4-@x, m1+a1)
	--@z=min(m3, l3)
	--@w=min(@y, @z)
	--@g=max(@w, n3)
	--@h=max(@g - a1, 0)
	--m1=@h
	--@k=min(@g - @h, a1)
	--a1=max(n2, @k)
	UPDATE main
	SET @spos = CASE 
			WHEN spt.superPT - main.masterPT - main.agentPT < 0
				THEN 0
			ELSE spt.superPT - main.masterPT - main.agentPT
			END
		, superPT = @spos
		, @mapos1 = CASE 
			WHEN @spos + main.masterPT + main.agentPT > spt.superPT
				THEN spt.superPT - @spos
			ELSE main.masterPT + main.agentPT
			END
		, @maxmapos = CASE 
			WHEN mpt.masterPT > mpt.maxPT
				THEN mpt.maxPT
			ELSE mpt.masterPT
			END
		, @mapos2 = CASE 
			WHEN @mapos1 > @maxmapos
				THEN @maxmapos
			ELSE @mapos1
			END
		, @mapos = CASE 
			WHEN @mapos2 < mpt.minPT
				THEN mpt.minPT
			ELSE @mapos2
			END
		, @mpos = CASE 
			WHEN @mapos - main.agentPT < 0
				THEN 0
			ELSE @mapos - main.agentPT
			END
		, masterPT = @mpos
		, @apos = CASE 
			WHEN main.agentPT + @mpos > @mapos
				THEN @mapos - @mpos
			ELSE main.agentPT
			END
		, agentPT = CASE 
			WHEN @apos < apt.minPT
				THEN apt.minPT
			ELSE @apos
			END
	FROM @memberPTTbl main
	INNER JOIN dbo.CustPTSetting3rd_Agent AS mpt WITH (NOLOCK)
		ON mpt.custid = @MasterID
			AND mpt.sporttype = main.sporttype
			AND mpt.bettype = main.bettype
			AND mpt.islive = main.Islive
	INNER JOIN dbo.CustPTSetting3rd_Agent AS spt WITH (NOLOCK)
		ON spt.custid = @SuperID
			AND spt.sporttype = main.sporttype
			AND spt.bettype = main.bettype
			AND spt.islive = main.Islive
	INNER JOIN dbo.CustPTSetting3rd_Agent AS apt WITH (NOLOCK)
		ON apt.custid = @AgentID
			AND apt.sporttype = main.sporttype
			AND apt.bettype = main.bettype
			AND apt.islive = main.Islive
	WHERE main.superPT + main.agentPT + main.masterPT > spt.superPT

	--Return XML result
	SELECT @CorrectedPT_XML = (
			SELECT *
			FROM @memberPTTbl
			FOR XML RAW('PT')
			)

	SELECT @CorrectedPT_XML = '<ROOT>' + @CorrectedPT_XML + '</ROOT>'
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DefaultMemberPTCorrect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DefaultMemberPTCorrect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DefaultMemberPTCorrect] TO [bodbExtAccNet]