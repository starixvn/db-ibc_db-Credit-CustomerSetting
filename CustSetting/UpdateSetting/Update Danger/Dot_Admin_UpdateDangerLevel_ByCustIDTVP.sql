/*<info serverAlias="DBCUST-CustDB" executers="Dot_Admin" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Dot_Admin_UpdateDangerLevel_ByCustIDTVP]
@CustIDTVP TVP_Integer Readonly,
@dangerlevel int = 0,
@dangerlevelvalueindex tinyint = null,
@manual_flag bit = 0
AS
/**
	custInfo.DangerLevel
	HEX: 0x   F      _           F         _     F
	       manualflag_basketballdangerlevel_soccerdangerlevel
	manualflag 
	BIN: 0 _ 0_      0   _  0
		 NA_NA_Basketball_Soccer
	
	Revisions:	 
		20200224@Anny(CustDB): Update Danger Level
		20200427@Anny(CustDB): update danger level by sportyype hex index:0(soccer)/1(basketball)
		20211005@Anny(CustDB): add update flag for manual set 
		20211018@Johnson(CustDB): add log for manual set
**/
BEGIN
	SET NOCOUNT ON;
	IF @dangerlevelvalueindex>1
		return;
	
	DECLARE @StartRun DATETIME, @Duration INT, @LogDataNew VARCHAR(500), @LogDataOld VARCHAR(500)

	SET @startRun = GETDATE()

	DECLARE @DataTypeOfLevel tinyint = POWER(2,4);
	CREATE TABLE #DangerCustInfo
	(
		custid int,
		dangerlevel int,
		soccer_dangerlevel tinyint,
		basketball_dangerlevel tinyint,
		manual_flag tinyint,
		updateDangerLevel int,
		Old_DangerLevel tinyint
	)
		
	;WITH cte AS
	(
	select custid,ISNULL(DangerLevel,0) as DangerLevel,
		(CASE WHEN @dangerlevelvalueindex is not null and @dangerlevelvalueindex=0 then @dangerlevel
			  ELSE ((ISNULL(DangerLevel,0)&(POWER(@DataTypeOfLevel,0)*(@DataTypeOfLevel-1)))/POWER(@DataTypeOfLevel,0))
			  END) as soccer_dangerlevel,
		(CASE WHEN @dangerlevelvalueindex is not null and @dangerlevelvalueindex=1 then @dangerlevel
			  ELSE ((ISNULL(DangerLevel,0)&(POWER(@DataTypeOfLevel,1)*(@DataTypeOfLevel-1)))/POWER(@DataTypeOfLevel,1))
			  END) as basketball_dangerlevel,
		((ISNULL(DangerLevel,0)&(POWER(@DataTypeOfLevel,2)*(@DataTypeOfLevel-1)))/POWER(@DataTypeOfLevel,2)) as manual_flag,
		(CASE WHEN @dangerlevelvalueindex is not null and @dangerlevelvalueindex=0 THEN
				((ISNULL(DangerLevel,0)&(POWER(@DataTypeOfLevel,0)*(@DataTypeOfLevel-1)))/POWER(@DataTypeOfLevel,0))
			WHEN @dangerlevelvalueindex is not null and @dangerlevelvalueindex=1 THEN 
				((ISNULL(DangerLevel,0)&(POWER(@DataTypeOfLevel,1)*(@DataTypeOfLevel-1)))/POWER(@DataTypeOfLevel,1)) 
			END) as Old_DangerLevel
	from dbo.custInfo with (nolock)
	Where Custid in ( select val from @CustIDTVP )
	)

	insert into #DangerCustInfo (custid,dangerlevel,soccer_dangerlevel,basketball_dangerlevel,manual_flag,Old_DangerLevel,updateDangerLevel)
	select custid,DangerLevel,soccer_dangerlevel,basketball_dangerlevel,manual_flag,Old_DangerLevel,
	updateDangerLevel =
		POWER(@DataTypeOfLevel,0)* soccer_dangerlevel + 
		POWER(@DataTypeOfLevel,1)* basketball_dangerlevel+
		POWER(2,8)*(CASE WHEN @dangerlevelvalueindex is not null and @dangerlevelvalueindex=0 then @manual_flag ELSE (manual_flag & 1) END)+
		POWER(2,9)*(CASE WHEN @dangerlevelvalueindex is not null and @dangerlevelvalueindex=1 then @manual_flag ELSE ((manual_flag & 2)/2) END)
	from cte
	
	Update dbo.custInfo WITH (ROWLOCK,UPDLOCK)
	set DangerLevel = t.updateDangerLevel
	output inserted.custid,inserted.username,inserted.dangerlevel
	FROM dbo.custInfo
	inner join #DangerCustInfo t on custInfo.custid = t.custid
	
		
	DECLARE @Log VARCHAR(MAX)
	
	SELECT @Log = CAST((
		SELECT custid as '@id',			
			@dangerlevelvalueindex as '@sport',
			@manual_flag as '@newflag',
			(manual_flag&POWER(2,@dangerlevelvalueindex))/POWER(2,@dangerlevelvalueindex) as '@oldflag',
			Old_DangerLevel as '@oldlevel',
			@DangerLevel as '@newlevel'
		FROM #DangerCustInfo t		
		WHERE (manual_flag&POWER(2,@dangerlevelvalueindex))/POWER(2,@dangerlevelvalueindex) <> @manual_flag	
		FOR XML PATH('r'), ROOT('Root')
	) AS VARCHAR(MAX))	
	
	SELECT @Duration = DATEDIFF (MILLISECOND, @startRun, GETDATE())
	
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.Acc_WriteLog_UserLog_RunSP_MultipleLog
			@UserId		= 10278938,	--StarixIT	
			@ActionId	= 1188,
			@Log		= @Log,		
			@IP			= '125.227.140.97',	
			@Duration	= @Duration
	END TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.Acc_WriteLog_UserLog_RunSP_MultipleLog
			@UserId		= 10278938,	--StarixIT
			@ActionId	= 1188,
			@Log		= @Log,		
			@IP			= '125.227.140.97',	
			@Duration	= @Duration			
	END CATCH

	DROP TABLE #DangerCustInfo
END
