SELECT 
	 [Prop ID] = u.scode 
   ,[Unit Status] = u.sstatus
   ,[Division] = RTRIM(at.subgroup10)
	,[Region] = RTRIM(at.subgroup18)
	,[District] = RTRIM(at.subgroup9)
	,[Market] = RTRIM(at.subgroup12)
	,[Address] = p.saddr1
	,[City] = p.scity
	,[State] = p.sstate
	,[Zip] = p.szipcode
	,[Field Super Assigned] = (SELECT superassigned 
											FROM crm.dbo.properties 
											WHERE propid=u.scode)
											
	,[General Contractor] = (SELECT generalcontractor 
											FROM crm.dbo.properties 
											WHERE propid=u.scode)
											
	,[Last Move Out] = (SELECT TOP 1 dtmoveout 
										FROM yardi_stage.dbo.tenant 
										WHERE u.hproperty = hproperty 
										AND istatus IN (0,1,2,3,4) 
										ORDER BY dtsigndate DESC)
										
	,[Most Recent Lifecycle] = (SELECT TOP 1 c.type 
												FROM crm.dbo.construction c 
												WHERE c.constructionid = (SELECT TOP 1 ch.constructionlifecycleid FROM crm.dbo.constructionhistory ch WHERE u.scode = left(ch.name,7) 
												ORDER BY ch.createdon DESC))
												
	,[Lifecycle Start Date] = (SELECT TOP 1 c.start 
												FROM crm.dbo.construction c 
												WHERE c.constructionid = (SELECT TOP 1 ch.constructionlifecycleid FROM crm.dbo.constructionhistory ch WHERE u.scode = left(ch.name,7) 
												ORDER BY ch.createdon DESC))
												
	,[Most Recent Status] = (SELECT TOP 1 ch.constructionstatus 
												FROM crm.dbo.constructionhistory ch 
												WHERE LEFT(ch.name,7) = u.scode 
												ORDER BY ch.createdon DESC)
												
	,[Status Start] = (SELECT TOP 1 ch.createdon 
									FROM crm.dbo.constructionhistory ch 
									WHERE LEFT(ch.name,7) = u.scode 
									ORDER BY ch.createdon DESC)
									
	,[Days In Status] = DATEDIFF(DAY,
										(SELECT TOP 1 ch.createdon FROM crm.dbo.constructionhistory ch WHERE LEFT(ch.name,7) = u.scode ORDER BY ch.createdon DESC),
										GETDATE())

	,[Days Since Last Vacate] = DATEDIFF(DAY,
													(SELECT TOP 1 dtmoveout FROM yardi_stage.dbo.tenant WHERE u.hproperty = hproperty AND istatus IN (0,1,2,3,4) ORDER BY dtsigndate DESC),
													GETDATE())

FROM yardi_stage.dbo.unit u

	LEFT JOIN yardi_stage.dbo.attributes at ON at.hprop = u.hproperty	
	LEFT JOIN yardi_stage.dbo.property p on p.hmy=u.hproperty

	WHERE u.sstatus IN ('Vacant Unrented Not Ready', 'Vacant Rented Not Ready')
	AND (SELECT TOP 1 dtmoveout 
					FROM yardi_stage.dbo.tenant 
					WHERE u.hproperty = hproperty 
					AND istatus IN (0,1,2,3,4)) IS NOT NULL
					
	AND DATEDIFF(DAY,
					(SELECT TOP 1 dtmoveout FROM yardi_stage.dbo.tenant WHERE u.hproperty = hproperty AND istatus IN (0,1,2,3,4) ORDER BY dtsigndate DESC),
					GETDATE()) >= 0
	AND (SELECT TOP 1 c.type 
				FROM crm.dbo.construction c 
				WHERE c.propid = u.scode 
				ORDER BY c.start DESC) != 'Initial Rehab' 
				
	AND (SELECT TOP 1 dtmoveout 
					FROM yardi_stage.dbo.tenant 
					WHERE u.hproperty = hproperty 
					AND istatus IN (0,1,2,3,4) 
					ORDER BY dtsigndate DESC) <= (SELECT TOP 1 c.start 
																	FROM crm.dbo.construction c 
																	WHERE c.propid = u.scode 
																	ORDER BY c.modifiedon DESC)
	
ORDER BY DATEDIFF(DAY,
						(SELECT TOP 1 dtmoveout FROM yardi_stage.dbo.tenant WHERE u.hproperty = hproperty AND istatus IN (0,1,2,3,4) ORDER BY dtsigndate DESC),
						GETDATE()) DESC