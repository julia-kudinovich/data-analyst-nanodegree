USE YARDI_STAGE;
SELECT 
 	 [Tenant Code] = t.scode
	,[Last Name] =  t.slastname
	,[Status] = ts.status
	,[Prop ID] = u.scode
	,[Event] = th.sevent
	,[Date] =  th.dtDate
	,[Times Tenant Went Into Evictions] = (SELECT COUNT(DISTINCT hmy) FROM yardi_stage.dbo.tenant_history WHERE htent=t.hmyperson AND sevent='Eviction')

FROM tenant_history th 
INNER JOIN tenant t ON t.hmyperson=th.htent
INNER JOIN unit u ON u.hmy=th.hunit
LEFT JOIN tenstatus ts ON ts.istatus=t.istatus

WHERE 1=1
AND th.sevent LIKE '%Cancel Eviction%'
AND t.istatus IN (0,3,4)
AND u.scode IN ('')
ORDER BY 4