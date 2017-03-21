SELECT DISTINCT top 1000 
    [Tenant ID] = t.scode
	,[Peospect ID] = p.scode
	,[Tenant Status] = ts.status
	,[Property ID] = u.scode
	,[Renewal count] = (SELECT SUM(CASE WHEN sevent='Lease Renewal' THEN 1
													WHEN sevent='Lease Renewal Canceled' THEN -1
													ELSE 0
													END) 
									FROM tenant_history 
									WHERE htent=t.hmyperson)

,[Credit Score] = app.score
,[Income] = app.income
,[Total Occupants] = app.total_occupants
,[Number of WO's (including canceled)] = (SELECT COUNT(DISTINCT scode) 
															FROM mm2wo 
															WHERE htenant=t.hmyperson)
,[Number of WO's (excluding canceled)] =(SELECT SUM(CASE 
																		WHEN sstatus!='Canceled' THEN 1 
																		ELSE 0 
															 		END) 
															FROM mm2wo 
															WHERE htenant=t.hmyperson)

,[Total cost of WO's (excluding canceled)] = (SELECT SUM(CASE 
																				WHEN sstatus!='Canceled' THEN ctotal0 
																				ELSE 0 
																			END) 
																	FROM mm2wo 
																	WHERE htenant=t.hmyperson)
																	
,[Number of Maintenance Phone Calls] = (SELECT COUNT(DISTINCT created_on) 
															FROM crm.dbo.phonecalls 
															WHERE tenant_id=t.scode)
															
,[Late Count by the Number of Late Fees] = (SELECT COUNT(DISTINCT hmy) 
																FROM trans 
																WHERE hoffsetacct=1332 
																AND hperson=t.hmyperson 
																AND stotalamount>0) 
,[Late Count from Tenant Table] = t.ilatecount
,[NSF Count from Tenant Table] = (SELECT insfcount FROM tenant WHERE hmyperson=t.hmyperson)  
,[NSF Count by the Number of NSF fees] = (SELECT COUNT(DISTINCT hmy) 
															FROM trans WHERE hoffsetacct=1331 
															AND hperson=t.hmyperson 
															AND stotalamount>0)
													- (SELECT COUNT(DISTINCT hmy) 
															FROM trans WHERE hoffsetacct=1331 
															AND hperson=t.hmyperson 
															AND stotalamount<0)
,[Times Went Into Evictions] = (SELECT COUNT(DISTINCT hmy) 
													FROM tenant_history 
													WHERE htent=t.hmyperson 
													AND sevent='Eviction')
													
,[Starting Rent] = (SELECT TOP 1 crent 
								FROM tenant_history 
								WHERE htent=t.hmyperson 
								AND sevent IN ('Deposit Change', 'Rent Change') 
								AND crent>0 
								ORDER BY dtOccurred ASC)
								
,[Ending Rent] = (SELECT TOP 1 crent 
								FROM tenant_history 
								WHERE htent=t.hmyperson 
								AND sevent IN ('Rent Change', 'Lease Renewal')
								ORDER BY dtOccurred DESC)
								
,[Length of Stay] = (CASE 
								WHEN t.dtmoveout IS  NOT NULL THEN DATEDIFF(DAY, t.dtmovein, t.dtmoveout) 
 								WHEN t.dtmoveout IS NULL THEN DATEDIFF(DAY, t.dtmovein, GETDATE())
 							END)	
 							
,[Month to Month Count] = (SELECT COUNT(DISTINCT hmy) 
											FROM tenant_history 
											WHERE htent=t.hmyperson 
											AND sevent='Month to Month')
											
,[Lengh of Month to Month] = (SELECT SUM(DATEDIFF(DAY, dtleasefrom,dtleaseto)) 
											FROM tenant_history 
											WHERE htent=t.hmyperson 
											AND sevent='Month to Month') 
									

FROM unit u 
	LEFT JOIN tenant t ON t.hproperty=u.hproperty
	INNER JOIN prospect p ON p.htenant=t.hmyperson
	LEFT JOIN tenstatus ts ON ts.istatus=t.istatus
	OUTER APPLY (SELECT TOP 1 * FROM applications.dbo.apps WHERE (t.scode=appid OR (appid=p.scode AND p.sstatus='Resident'))) app

WHERE (SELECT COUNT(sevent) 
				FROM tenant_history 
				WHERE sevent='Lease Renewal' 
				AND htent=t.hmyperson)
		 -
		 
		(SELECT COUNT(sevent) 
				FROM tenant_history 
				WHERE sevent='Lease Renewal Canceled' 
				AND htent=t.hmyperson) > 0
