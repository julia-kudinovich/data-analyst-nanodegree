SELECT DISTINCT 
 [Property] = c.propid
,[Market] = p.market
,[Super Assigned] = p.superassigned
,[Electric Utility Company] = p.electricutilityco
,[Gas Utility Company] = p.Gasutilityco
,[Water Utility Company] = p.waterutilityco
,[Lifecycle Type] = c.type
,[Lifecycle Status] = c.constructionstatus 
,[Initial Inspection Start Date] = ch.start
,[Initial Inspection End Date] = ch.enddate
,[Length of Time in Inspection] = (CASE WHEN ch.enddate IS NULL AND c.constructionstatus='Initial Inspection' 
																		THEN datediff(day,ch.start,getdate())
													 WHEN ch.enddate IS NULL AND c.constructionstatus!='Initial Inspection' 
																		THEN datediff(day,ch.start, (SELECT TOP 1 start 
																															FROM crm.dbo.constructionhistory 
																															WHERE left(name,7)=c.propid 
																															AND constructionstatus != 'Initial Inspection'-- not to pick up same date as ch.start
																															AND start>=ch.start ORDER BY start ASC))
																													
													 WHEN ch.enddate IS NULL AND (SELECT TOP 1 constructionstatushistory 
																															FROM crm.dbo.constructionhistory 
																															WHERE left(name,7)=c.propid 
																															AND start>=ch.start ORDER BY start ASC) = ch.constructionstatushistory
																		THEN datediff(day,ch.start, getdate())
																															
													ELSE datediff(day,ch.start,ch.enddate)
											 END)		

FROM crm.dbo.construction c
LEFT JOIN crm.dbo.constructionhistory ch ON (ch.constructionlifecycleid=c.constructionid  AND ch.constructionstatus = 'Initial Inspection' AND ch.status=0)
Inner Join crm.dbo.properties p on p.propid=c.propid


WHERE c.type='Initial Rehab' 
AND c.status=0 -- 0 means displayed on CRM Constr History Page/active, 1 - not active
AND ch.start IS NOT NULL

order by 1