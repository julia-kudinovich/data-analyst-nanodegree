SELECT DISTINCT 

 [Prop ID] = u.scode
,[Prop Status] = u.sstatus
,[Division] = rtrim(at.subgroup10)
,[Region] = rtrim(at.subgroup18)
,[District] = rtrim(at.subgroup9)
,[Market] = rtrim(at.subgroup12)
,[Market Area] = rtrim(at.subgroup13)
,[Old Tenant Code] = t.scode
,[Old Tenant Status] = (SELECT status FROM yardi_stage.dbo.tenstatus WHERE istatus = t.istatus)
,[Lease From] = t.dtleasefrom
,[Lease To] = t.dtleaseto
,[Move In] = t.dtmovein
,[Move Out] = t.dtmoveout
,[New Tenant Code] = ten2.scode
,[Next Lease Sign] = CAST(ls.dtoccurred AS DATE)
,[Next Move In] = CAST(ten2.dtmovein AS DATE)
,[Last Lifecycle] = llc.type
,[Current Lifecycle] = clc.type
,[Current Lifecycle Start] = CAST(clc.start AS DATE)
,[Time to Create LC] = DATEDIFF(DAY,t.dtmoveout,clc.start)
,[Current Lifecycle Status] = clc.constructionstatus
,[Rent Ready] = CAST(rr.start AS DATE)
,[Days in Construction] = 
	(CASE 
		WHEN
			rr.start IS NULL
				THEN DATEDIFF(DAY,
									(CASE 
										WHEN clc.start IS NULL
											THEN t.dtmoveout
										WHEN clc.start > t.dtmoveout
											THEN clc.start
										ELSE t.dtmoveout
									END) 
								,GETDATE())
		ELSE DATEDIFF(DAY,(CASE 
										WHEN clc.start IS NULL
											THEN t.dtmoveout
										WHEN clc.start > t.dtmoveout
											THEN clc.start
										ELSE t.dtmoveout
									END) 
								,rr.start)
	END)
,[Marketing Time]	= DATEDIFF(DAY,rr.start,ls.dtoccurred)
,[Sign to Start] = DATEDIFF(DAY,ls.dtoccurred,ten2.dtmovein)
,[Total Turn Time] = DATEDIFF(DAY,	(CASE 
										WHEN clc.start IS NULL
											THEN t.dtmoveout
										WHEN clc.start > t.dtmoveout
											THEN clc.start
										ELSE t.dtmoveout
									END) 
										, ten2.dtmovein)
,[Total Vacancy Period] = DATEDIFF(DAY,t.dtmoveout,ten2.dtmovein)
,[Not Ready?] = (CASE
					 	WHEN 
							rr.start IS NULL
								THEN 1
						ELSE 0
					 END)
,[Open Turn?] = (CASE
					 	WHEN 
							ten2.dtmovein IS NULL
								THEN 1
						ELSE 0
					END) 	
,[Days since Move Out] = (CASE
									WHEN DATEDIFF(DAY,t.dtmoveout,getdate()) <31
										THEN '0-30'
									WHEN DATEDIFF(DAY,t.dtmoveout,getdate()) <61
										THEN '31-60'
									WHEN DATEDIFF(DAY,t.dtmoveout,getdate()) <91
										THEN '61-90'
									WHEN DATEDIFF(DAY,t.dtmoveout,getdate()) <181
										THEN '91-180'	
									ELSE '181+'
								END)
								
,[Total Turn Cost] = (SELECT sum(d.dtotalcost)
									FROM yardi_stage.dbo.mm2po po
									LEFT JOIN yardi_stage.dbo.mm2podet d ON po.hmy = d.hpo
									INNER JOIN yardi_stage.dbo.wf_tran_header wfth ON (po.hmy = wfth.hrecord AND wfth.iType = 26)
									WHERE d.hprop = u.hproperty
									AND po.dtordereddate BETWEEN t.dtmoveout - 14 AND (CASE 
																											 WHEN ls.dtoccurred IS NULL
																													THEN GETDATE()
																											 ELSE ls.dtoccurred
																											END)
									AND wfth.istatus NOT IN (2,3) /* approval status is not 'canceled' and is not 'rejected'*/
									AND po.sexptype != 'Bulk')
									
	,[Paid PO cost] = (SELECT sum(d.dtotalcost)
										FROM yardi_stage.dbo.mm2po po
										LEFT JOIN yardi_stage.dbo.mm2podet d ON po.hmy = d.hpo
										INNER JOIN yardi_stage.dbo.wf_tran_header wfth ON (po.hmy = wfth.hrecord AND wfth.iType = 26)
										WHERE d.hprop = u.hproperty
										AND po.dtordereddate BETWEEN t.dtmoveout - 14 AND (CASE 
																													WHEN ls.dtoccurred IS NULL
																														THEN GETDATE()
																													ELSE ls.dtoccurred
																											END)
										AND wfth.istatus NOT IN (2,3)
										AND po.sexptype != 'Bulk'
										AND STUFF((SELECT TOP 1 hpayable
																FROM yardi_stage.dbo.glinvregTrans
																WHERE hmy = (SELECT TOP 1 hinvorrec
																							FROM yardi_stage.dbo.glinvregdetail
																							WHERE hpodet = d.hmy)
																ORDER BY sdateoccurred DESC
																), 1, 3, '') IS NOT NULL /* Payable ctrl# is present*/)
																
	,[Approved PO Cost] = (SELECT sum(d.dtotalcost)
											FROM yardi_stage.dbo.mm2po po
											LEFT JOIN yardi_stage.dbo.mm2podet d ON po.hmy = d.hpo
											INNER JOIN yardi_stage.dbo.wf_tran_header wfth ON (po.hmy = wfth.hrecord AND wfth.iType = 26)
											WHERE d.hprop = u.hproperty
											AND po.dtordereddate BETWEEN t.dtmoveout - 14 AND (CASE 
																													WHEN ls.dtoccurred IS NULL
																														THEN GETDATE()
																													ELSE ls.dtoccurred
																													END)
											AND wfth.istatus NOT IN (2,3)
											AND po.sexptype != 'Bulk'
											AND wfth.istatus = 1 /*approval status: 'completed' */)
											
	,[Pending Approval PO Cost] = (SELECT sum(d.dtotalcost)
													FROM yardi_stage.dbo.mm2po po
													LEFT JOIN yardi_stage.dbo.mm2podet d ON po.hmy = d.hpo
													INNER JOIN yardi_stage.dbo.wf_tran_header wfth ON (po.hmy = wfth.hrecord AND wfth.iType = 26)
													WHERE d.hprop = u.hproperty
													AND po.dtordereddate BETWEEN t.dtmoveout - 14 AND (CASE 
																															WHEN ls.dtoccurred IS NULL
																																THEN GETDATE()
																															ELSE ls.dtoccurred
																															END)
													AND wfth.istatus NOT IN (2,3)
													AND po.sexptype != 'Bulk'
													AND d.bclosed = 0
													AND wfth.istatus = 0 /*approval status: 'in process' */)



FROM yardi_stage.dbo.tenant t

INNER JOIN yardi_stage.dbo.unit u ON u.hproperty = t.hproperty
INNER JOIN yardi_stage.dbo.attributes at ON at.hprop = t.hproperty

OUTER APPLY 
	(SELECT TOP 1 * 
				FROM crm.dbo.construction crmc 
				WHERE type IN ('Initial Rehab','Tenant Turn B') 
				AND crmc.propid = t.sunitcode 
				AND start < t.dtmoveout 
		ORDER BY start DESC) llc

OUTER APPLY 
	(SELECT TOP 1 * 
				FROM crm.dbo.construction crmc 
				WHERE type IN ('Initial Rehab','Tenant Turn B') 
				AND crmc.propid = t.sunitcode 
				AND start >= (t.dtmoveout - 45) 
	ORDER BY start ASC) clc

OUTER APPLY
	(SELECT TOP 1 start 
			FROM crm.dbo.constructionhistory ch 
			WHERE ch.name = CONCAT(u.scode,'- Rent Ready') 
			AND start >= t.dtmoveout 
			ORDER BY start ASC) rr

OUTER APPLY
	(SELECT TOP 1 *
			 FROM yardi_stage.dbo.tenant_history 
			 WHERE htent = (SELECT TOP 1 t2.hmyperson 
			 								FROM yardi_stage.dbo.tenant t2 
											 WHERE t2.dtsigndate >= t.dtmoveout 
											 AND t.sunitcode = t2.sunitcode 
											 AND t2.istatus IN (0,1,2,3,4) 
									ORDER BY t2.dtsigndate ASC) 
			AND sevent = 'Lease Signed' 
			ORDER BY dtoccurred ASC) ls

OUTER APPLY
	(SELECT TOP 1 t2.* 
				FROM yardi_stage.dbo.tenant t2 
				WHERE t2.dtsigndate >= t.dtmoveout 
				AND t.sunitcode = t2.sunitcode 
				AND t2.istatus IN (0,1,2,3,4) 
	ORDER BY t2.dtsigndate ASC) ten2

WHERE 1 = 1

AND t.dtmoveout <= getdate()
AND (clc.type = 'Tenant Turn B' OR (clc.type IS NULL AND llc.type IN ('Initial Rehab', 'Tenant Turn B'))) /* If you want to see all lifecycles, including rehabs, comment out this last And clause*/
