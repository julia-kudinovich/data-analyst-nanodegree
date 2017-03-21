SELECT DISTINCT top 100
	 [PO#] = po.scode
	,[Parent PO#] = po.hpo
	,[PO Line Item#] = d.hmy
	,[Property] = dp.scode
	,[Unit Status] = u.sstatus
	,[Division] = RTRIM(at.subgroup10)
	,[Region] = RTRIM(at.subgroup18)
	,[District] = RTRIM(at.subgroup9)
	,[Market] = RTRIM(at.subgroup12)
	,[Legacy] = (CASE 
					WHEN prev_ten.dtmoveout >=(SELECT certificationdate FROM crm.dbo.properties WHERE propid=dp.scode) 
					THEN 0 ELSE 1 
					END)
	,[Certification Date] = CONVERT(date,(SELECT certificationdate FROM crm.dbo.properties WHERE propid=dp.scode))
	,[Rent Ready Date] = (SELECT TOP 1 CONVERT(date, start) 
   								FROM   [crm].[dbo].[constructionhistory] 
   								WHERE dp.scode LIKE LEFT(NAME, 7) AND constructionstatus = 'Rent Ready' 
   								ORDER  BY start DESC)
	
	,[Last Move Out Date] = CONVERT(date,prev_ten.dtmoveout)
	
	,[Vendor ID] = ISNULL(mv.ucode, '')
	,[Vendor Name] = mv.ulastname
	,[Total PO Cost] = po.dtotal -- sum of line item costs
	,[PO Order Date] = CONVERT(date,po.dtordereddate)
	,[PO Expense Type] = po.sexptype
	,[PO Requestor] = po.srequestedby
	,[PO Description] = po.sdesc
	,[PO Notes] = po.snotes
	
	,[PO Scheduled Delivery Date] = po.dtscheddeldate
	,[PO Last Received Date] = po.dtactdeldate
	,[PO Payment Due Date] = po.dtpayduedate
	,[PO Required By Date] = po.dtreqdate
	,[PO Date In] = po.dtdatein
	,[PO Close Date] = po.dtclose
	,[PO From Date] = po.dtfrom
	,[PO To Date] = po.dtto
	,[PO Modified Date] = po.dtdatemodified
	,[PO Status] = (CASE 
							WHEN ((SELECT SUM(iqtyordered) FROM yardi_stage.dbo.mm2podet WHERE hpo=po.hmy) - (SELECT SUM(iqtyreceived) FROM yardi_stage.dbo.mm2podet WHERE hpo=po.hmy))=0 THEN 'Received'
							WHEN (SELECT SUM(iqtyordered) FROM yardi_stage.dbo.mm2podet WHERE hpo=po.hmy)>(SELECT SUM(iqtyreceived) FROM yardi_stage.dbo.mm2podet WHERE hpo=po.hmy) AND
(SELECT SUM(iqtyreceived) FROM yardi_stage.dbo.mm2podet WHERE hpo=po.hmy)>0 THEN 'Partially Received'
							WHEN (SELECT SUM(iqtyreceived) FROM yardi_stage.dbo.mm2podet WHERE hpo=po.hmy)=0 AND (SELECT SUM(iqtyordered) FROM yardi_stage.dbo.mm2podet WHERE hpo=po.hmy)>0 THEN 'Not Received'
							WHEN (SELECT SUM(iqtyordered) FROM yardi_stage.dbo.mm2podet WHERE hpo=po.hmy) <0  THEN 'Not Received'
						END)
						
	,[Invoice/No Invoice] = (CASE
										WHEN (SELECT TOP 1 hinvorrec FROM yardi_stage.dbo.glinvregdetail WHERE hpodet=d.hmy ) is not null then 'Invoice'
										WHEN (SELECT TOP 1 hinvorrec FROM yardi_stage.dbo.glinvregdetail WHERE hpodet=d.hmy ) is null then 'No Invoice'
									END)
	,[Approval Status] = (CASE wfth.istatus
										WHEN 0 THEN 'In Process' 
										WHEN 1 THEN 'Completed' 
										WHEN 2 THEN 'Cancelled' 
										WHEN 3 THEN 'Rejected' 
										ELSE '' 
								END)
	,[Workflow Current Step] = (SELECT TOP 1 ws.sname FROM yardi_stage.dbo.wf_step ws LEFT JOIN yardi_stage.dbo.wf_tran_step_current wts ON wts.hstep=ws.hmy WHERE wts.htranheader= wfth.hmy)
		
		
	,[Item Type] = ms.scode
	,[Item Description] = d.sdesc
   ,[GL Account] = (SELECT scode FROM yardi_stage.dbo.acct WHERE hmy=d.hpayacct)
	,[GL Account Description] = (SELECT sdesc FROM yardi_stage.dbo.acct WHERE hmy=d.hpayacct)
	,[Quantity Ordered] = d.iqtyordered 
	,[Unit Price] = d.dunitprice
	,[Base Total] = d.dtotalcost -- line item cost
	,[Status] = (CASE d.bclosed 
							WHEN 0 THEN 'Open' 
							ELSE 'Closed' 
					END)
	
	,[Payable Ctrl#] = (SELECT TOP 1  hpayable FROM yardi_stage.dbo.glinvregTrans WHERE hmy=(SELECT TOP 1 hinvorrec FROM yardi_stage.dbo.glinvregdetail WHERE hpodet=d.hmy) ORDER BY sdateoccurred DESC)-300000000 
	,[IR Ctrl#] = (SELECT TOP 1 hinvorrec FROM yardi_stage.dbo.glinvregdetail WHERE hpodet=d.hmy )
	

	,[Paid?] = (CASE 
						WHEN STUFF((SELECT TOP 1  hpayable FROM yardi_stage.dbo.glinvregTrans WHERE hmy=(SELECT TOP 1 hinvorrec FROM yardi_stage.dbo.glinvregdetail WHERE hpodet=d.hmy) ORDER BY sdateoccurred DESC),1,3,'') IS NOT NULL THEN 'Yes'
							ELSE 'No'
							END)
	
	,[Check No] = (SELECT UREF FROM yardi_stage.dbo.trans WHERE hmy=(SELECT top 1 hchkorchg FROM yardi_stage.dbo.detail WHERE hpodet=d.hmy AND hChkOrChg IS NOT NULL)) 
	,[Check Date] = (SELECT sdateoccurred FROM yardi_stage.dbo.trans WHERE hmy=(SELECT top 1 hchkorchg FROM yardi_stage.dbo.detail WHERE hpodet=d.hmy AND hChkOrChg IS NOT NULL )) 
	,[Post Month] = CONCAT(month((SELECT upostdate FROM yardi_stage.dbo.trans WHERE hmy=(SELECT top 1 hchkorchg FROM yardi_stage.dbo.detail WHERE hpodet=d.hmy AND hChkOrChg IS NOT NULL))), '/', year((SELECT upostdate FROM yardi_stage.dbo.trans WHERE hmy=(SELECT top 1 hchkorchg FROM yardi_stage.dbo.detail WHERE hpodet=d.hmy AND hChkOrChg IS NOT NULL )))) 
	
	,[Payable Approved] = (CASE 
										WHEN yardi_stage.dbo.ApprChk_PayScan (po.hmy) = 1 THEN 1	
										ELSE 0	
									END)

	
	,[Quantity Received] = d.iqtyreceived
	,[Received Day] = d.dtreceiveddate
	
	
	,[Tenant ID] = ten.scode
	,[Tenant Lease From] = ten.dtleasefrom
	,[Tenant Lease To] = ten.dtleaseto
	,[Tenant Move In] = ten.dtmovein
	,[Tenat Move Out] = ten.dtmoveout
	,[Times Tenant Went Into Evictions] = (SELECT COUNT(DISTINCT hmy) FROM yardi_stage.dbo.tenant_history WHERE htent=ten.hmyperson AND sevent='Eviction')
	,[# of Renewals by Tenant] = (SELECT COUNT(sevent) FROM yardi_stage.dbo.tenant_history WHERE sevent='Lease Renewal' AND htent=ten.hmyperson)
										- (SELECT COUNT(sevent) FROM yardi_stage.dbo.tenant_history WHERE sevent='Lease Renewal Canceled' AND htent=ten.hmyperson)
										
	/*									
	,[CRM Current Rent Ready Date] =  cp.currentrentready
	,[Purchase Date] = cp.dateacquired
 	,[In Service Date] = cp.inservicedate
	,[Conversion Date] = cp.conversiondate
	,[Purchase Price] = cp.purchaseprice
	,[UW Rehab] = cp.projectedrehab
   ,[Super Assigned] = cp.superassigned
	,[Primary GC] = cp.generalcontractor
	,[Entity] = cp.entity
	,[Acquired Type] = cp.acquiredtype
	,[Construction Status] = (SELECT TOP 1 constructionstatus 
												FROM crm.dbo.constructionhistory 
												WHERE LEFT(name,7)=dp.scode 
												ORDER BY start DESC)
  */


FROM  yardi_stage.dbo.mm2po po
	LEFT JOIN yardi_stage.dbo.mm2podet d ON po.hmy = d.hpo
	INNER JOIN yardi_stage.dbo.property dp ON d.hprop = dp.hmy
	LEFT JOIN yardi_stage.dbo.mm2stock ms ON ms.hmy = d.hstock
	LEFT JOIN yardi_stage.dbo.unit u ON dp.scode = u.scode
	LEFT JOIN yardi_stage.dbo.person mv ON mv.hmy = po.hvendor
	LEFT JOIN yardi_stage.dbo.attributes at ON at.hprop = dp.hmy 
	OUTER APPLY (SELECT TOP 1 * FROM yardi_stage.dbo.tenant WHERE sunitcode=dp.scode ORDER BY dtmoveout DESC) prev_ten      
	OUTER APPLY (SELECT TOP 1 * FROM yardi_stage.dbo.tenant WHERE sunitcode=dp.scode AND istatus IN (0,1,2,3,4) AND dtsigndate<dtCreated ORDER BY dtsigndate DESC) ten
	OUTER APPLY (SELECT TOP 1 * FROM crm.dbo.properties where propid=dp.scode) cp
	OUTER APPLY (SELECT TOP 1 * FROM yardi_stage.dbo.wf_tran_header where po.hmy = hrecord and iType=26 order by hmy desc) wfth
     
-- WHERE 

	-- AND  wfth.istatus  NOT IN (2,3) -- not cancelled or rejected
	-- AND po.sexptype IN ('Rehab', 'Turn', 'Maintenance and Repair', 'Bulk')

	
	-- UNCOMMENT FOR TURN PO
/*
AND po.dtordereddate BETWEEN prev_ten.dtmoveout AND 
	(CASE 
		WHEN (SELECT TOP 1 dtmovein 
					FROM yardi_stage.dbo.tenant 
					WHERE sunitcode=dp.scode 
					AND istatus IN  (0,1,2,3,4) ORDER BY dtmovein DESC) > prev_ten.dtmoveout THEN (SELECT TOP 1 dtmovein 
																																	FROM yardi_stage.dbo.tenant 
																																	WHERE sunitcode=dp.scode 
																																	AND istatus IN (0,1,2,3,4) 
																																	ORDER BY dtmovein DESC)
		ELSE GETDATE() 
	END)  */


ORDER BY dp.scode