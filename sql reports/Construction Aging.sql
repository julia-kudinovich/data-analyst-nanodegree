SELECT 
 [Prop ID] = p.propId
,[Market] = RTRIM(a.subgroup12)

-- Selects a move out date of the last tenant
,[Last Move Out Date] = (SELECT TOP 1 dtmoveout 
										  FROM yardi_stage.dbo.tenant 
										  WHERE sunitcode=p.propid 
										  ORDER BY dtsigndate DESC)
										  
-- Selects the name of a construction lifecycle from CRM Construction table
,[Construction Lifecycle] = (SELECT TOP 1 type 
												FROM crm.dbo.construction 
												WHERE LEFT(name,7)=p.propId 
												ORDER BY start DESC)
												
-- Selects the start date of a construction lifecycle
,[Lifecycle Start Date] = (SELECT TOP 1 start 
											FROM crm.dbo.construction 
											WHERE LEFT(name,7)=p.propId 
											ORDER BY start DESC)
											
-- Selects the name of a construction status from CRM Construction History table											
,[Construction History Status] = (SELECT TOP 1 ConstructionStatus 
														FROM crm.dbo.constructionhistory WHERE LEFT(name,7)=p.propId 
														ORDER BY start DESC)
														
-- Selects the start date of a construction status														
,[Start of Construction History Status] = (SELECT TOP 1 start 
																	FROM crm.dbo.constructionhistory 
																	WHERE LEFT(name,7)=p.propId 
																	ORDER BY start DESC)
																	
-- Counts how many days the propertry was in the last constuction status
,[Lengh of Construction History Status] = DATEDIFF(DAY,
																	(SELECT TOP 1 start 
																			FROM crm.dbo.constructionhistory 
																			WHERE LEFT(name,7)=p.propId 
																			ORDER BY start DESC), 
																	GETDATE())
																	
-- Counts for how many days the property was in construction. If there was a previous lease it counts the number of days between previous tenant's move out date and current date. If there were no leases on the property it counts the number of dats between getting into construction status and the current date.																	
,[Days Vacant] = (CASE 
							WHEN (SELECT TOP 1 dtmoveout 
											FROM yardi_stage.dbo.tenant 
											WHERE sunitcode=p.propid 
											ORDER BY dtsigndate DESC) IS NULL 
							THEN DATEDIFF(DAY, 
											 (SELECT TOP 1 start 
																FROM crm.dbo.construction 
																WHERE LEFT(name,7)=p.propId 
																ORDER BY start DESC),
												GETDATE()) 
							ELSE DATEDIFF(DAY, 
											 (SELECT TOP 1 dtmoveout 
															FROM yardi_stage.dbo.tenant 
															WHERE sunitcode=p.propid 
															ORDER BY dtsigndate DESC), 
												GETDATE()) 
						END)


FROM crm.dbo.properties p
LEFT JOIN yardi_stage.dbo.property ysp ON ysp.scode = p.propid
LEFT JOIN yardi_stage.dbo.attributes a ON a.hprop = ysp.hmy
WHERE p.unitstatus IN ('Vacant Unrented Not Ready','Vacant Rented Not Ready')
AND (CASE 
		WHEN (SELECT TOP 1 dtmoveout 
						FROM yardi_stage.dbo.tenant 
						WHERE sunitcode=p.propid 
						ORDER BY dtsigndate DESC) IS NULL 
		THEN DATEDIFF(DAY, 
						 (SELECT TOP 1 start 
						 			FROM crm.dbo.construction 
									WHERE LEFT(name,7)=p.propId 
									ORDER BY start DESC),
						 GETDATE()) 
	  	ELSE DATEDIFF(DAY, 
		  				 	(SELECT TOP 1 dtmoveout 
										FROM yardi_stage.dbo.tenant 
										WHERE sunitcode=p.propid 
										ORDER BY dtsigndate DESC),  
						 GETDATE()) 
	END) > 60
