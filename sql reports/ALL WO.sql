SELECT DISTINCT 
top 1000
     [WO#] = wo.scode
    ,[Related WO] = wo.hrelwo 
	,[WO Line Item#] =  wod.hmy
	,[Property]  = p.scode
	,[Division] = RTRIM(at.subgroup10)
	,[Region] = RTRIM(at.subgroup18)
	,[District] = RTRIM(at.subgroup9)
	,[Market] = RTRIM(at.subgroup12)
	,[Legacy] = (CASE 
					WHEN prev_ten.dtmoveout >=(SELECT certificationdate FROM crm.dbo.properties WHERE propid=p.scode) 
					THEN 0 ELSE 1 
					END)
	,[Certification Date] = CONVERT(date,(SELECT certificationdate FROM crm.dbo.properties WHERE propid=p.scode))
	,[Rent Ready Date] = (SELECT TOP 1 CONVERT(date, start) 
   								FROM   [crm].[dbo].[constructionhistory] 
   								WHERE p.scode LIKE LEFT(NAME, 7) AND constructionstatus = 'Rent Ready' 
   								ORDER  BY start DESC)
	,[Tenant ID] = t.scode
	,[Lease From] = t.dtleasefrom
	,[Lease To] = t.dtleaseto
	,[Move In] = t.dtmovein
	,[Move Out] = t.dtmoveout
	,[Times Went Into Evictions] = (SELECT COUNT(DISTINCT hmy) FROM yardi_stage.dbo.tenant_history WHERE htent=t.hmyperson AND sevent='Eviction')
	,[# of Renewals] = (SELECT COUNT(sevent) FROM yardi_stage.dbo.tenant_history WHERE sevent='Lease Renewal' AND htent=t.hmyperson)
						  - (SELECT COUNT(sevent) FROM yardi_stage.dbo.tenant_history WHERE sevent='Lease Renewal Canceled' AND htent=t.hmyperson) 
	,[Vendor ID] = ISNULL(v.ucode, '')
	,[Vendor Name] = v.ulastname
	,[WO Priority] = wo.spriority
	,[WO Status] = wo.sstatus
	,[WO Reason] = wo.sreason
	,[WO Category] =  wo.SCATEGORY
	,[WO Subcategory] =  wo.SSUBCAT
	,[WO Brief Description] = wo.SBRIEFDESC
	,[WO Problem Description] = wo.sprobdescnotes
	,[WO Full Description] = wo.sfulldesc
	,[WO Resolution] = wo.sResolution
	,[Access/Entry Notes] = wo.saccessnotes
	,[Technician Notes] = wo.stechnotes
	,[Caller Name] = wo.scallername
	,[Call Date] = wo.dtcall
	,[In Progress] = CASE WHEN (SELECT top 1 dtusermodified FROM yardi_stage.dbo.wohistory where hwo=wo.hmy and sstatus='In Progress' order by dtusermodified desc) is NULL 
									THEN wo.dtinprog
									ELSE (SELECT top 1 dtusermodified FROM yardi_stage.dbo.wohistory where hwo=wo.hmy and sstatus='In Progress' order by dtusermodified desc) 
									END
	,[WO Due Date] = wo.dtdue
	,[Service Complete Date] = (SELECT top 1 dtusermodified FROM yardi_stage.dbo.wohistory where hwo=wo.hmy and sstatus='Service Complete' order by dtusermodified desc)
	,[Pending Invoice] = wo.dtuser5
	,[Pending Payment] = (SELECT TOP 1 dtusermodified FROM yardi_stage.dbo.wohistory WHERE hwo=wo.hmy AND sstatus='Pending Payment' ORDER BY dtusermodified DESC)
	,[Dispatched Date]  = wo.dtuser2
	,[Follow-Up  Date]  = wo.dtuser3
	,[Request Re-assignment] = wo.dtrequestreassignment
	,[On Hold] = (SELECT top 1 dtusermodified FROM yardi_stage.dbo.wohistory where hwo=wo.hmy and sstatus='On Hold' order by dtusermodified desc)
    ,[Work Completed] = (SELECT top 1 dtusermodified FROM yardi_stage.dbo.wohistory where hwo=wo.hmy and sstatus='Work Completed' order by dtusermodified desc)
	,[In-House] = (SELECT top 1 dtusermodified FROM yardi_stage.dbo.wohistory where hwo=wo.hmy and sstatus='In-House' order by dtusermodified desc)
	,[WO Created By] = wo.SREQUESTEDBY
	,[WO Created Date] = wo.DTDATEIN
	,[WO Updated By] = wo.SUPDATEDBY
	,[WO Updated Date] = wo.DTUPDATEDT
	,[Approval Status] = (CASE wfth.istatus 
									WHEN 0 THEN 'In Process' 
									WHEN 1 THEN 'Completed' 
									WHEN 2 THEN 'Cancelled' 
									WHEN 3 THEN 'Rejected' 
									ELSE '' 
									END) 
   ,[Current Workflow Step] = (SELECT TOP 1 ws.sname FROM yardi_stage.dbo.wf_step ws LEFT JOIN yardi_stage.dbo.wf_tran_step_current wts ON wts.hstep=ws.hmy WHERE wts.htranheader= wfth.hmy) 
    ,[In-House Reassignment] = wo.suser3
	,[WO Approved By] = au.uName
	,[WO Approved Date] = wfs.dtComplete
	,[WO Schedule Date] = wo.dtsched
	,[WO Cancel Date]  = wo.dtcanc
	,[WO Invoice Date] = wo.dtinvoice
	,[WO Invoice #] = wo.sinvno
	,[Payable Batch #] = (CASE 
										WHEN wo.hpayrcd>0 THEN wo.hpayrcd-1100000000  
										ELSE NULL 
								END)
	,[Charge Batch #] = (CASE 
									WHEN wo.hchgrcd>0 THEN wo.hchgrcd-1600000000 
									ELSE NULL 
								END)
								
    ,[WO Material Item Type] =  isnull(wos.scode, '')
	,[WO Material Item Description]  = wod.SDESC
	,[WO Material Quantity] = wod.DQUAN
	,[WO Material Unit Pay] = wod.DUNITPRICE
	,[WO Material Pay Total] = wod.DPAYAMT
	,[WO Material Unit Charge] = wod.dchgunitprice
	,[WO Material Charge Total] = wod.dchgamt
	,[WO Material Charge Code] = (SELECT scode FROM yardi_stage.dbo.chargtyp WHERE hmy=wod.hchgcode)
	,[GL Pay Account Code] = (SELECT scode FROM yardi_stage.dbo.acct WHERE hmy=wod.hpayacct)
	,[GL Pay Account Description] = (SELECT sdesc FROM yardi_stage.dbo.acct WHERE hmy=wod.hpayacct)
	,[Pay Box Checked/Unchecked] = (CASE
												 WHEN wod.bdetpay=-1 THEN 'Checked' 
													ELSE 'Unchecked' 
												END)
	,[Charge Box Checked/Unchecked] = (CASE
													WHEN wod.bdetchg=-1 THEN 'Checked' 
													ELSE 'Unchecked'
												END)
	,[Attachment] = (SELECT COUNT(hmy) FROM yardi_stage.dbo.pmdocs WHERE hrecord=wo.hmy AND itype=25 )
	    
FROM 
    yardi_stage.dbo.mm2wo wo 
        INNER JOIN yardi_stage.dbo.property p ON p.hmy = wo.hproperty
        LEFT JOIN yardi_stage.dbo.tenant t ON t.hmyperson = wo.htenant
        LEFT JOIN yardi_stage.dbo.attributes at ON at.hprop=p.hmy    
        LEFT JOIN yardi_stage.dbo.vendor v ON v.hmyperson = wo.hvendor
   
        LEFT JOIN yardi_stage.dbo.wf_tran_step wfs ON (wfs.hrecord = wo.hmy AND wfs.bcurrent = -1 AND wfs.itype = 25)
        LEFT JOIN yardi_stage.dbo.mm2wodet wod ON wod.hwo = wo.hmy
        LEFT JOIN yardi_stage.dbo.mm2stock wos ON wos.hmy = wod.hstock
        LEFT JOIN yardi_stage.dbo.pmUser au ON wfs.hUserComplete = au.hMy
        	OUTER APPLY (SELECT TOP 1 * FROM yardi_stage.dbo.wf_tran_header where wo.hmy = hrecord and iType=25 order by hmy desc) wfth
		  OUTER APPLY (SELECT TOP 1 * FROM yardi_stage.dbo.tenant WHERE sunitcode=p.scode ORDER BY dtmoveout DESC) prev_ten  	
 WHERE
 at.subgroup12 NOT IN ('Corp')
 AND at.subgroup12  IS NOT NULL

	 -- UNCOMMENT FOR TURN WO 
	
/*	AND wo.dtcall BETWEEN prev_ten.dtmoveout AND 
	(CASE 
		WHEN (SELECT TOP 1 dtmovein 
					FROM yardi_stage.dbo.tenant 
					WHERE sunitcode=p.scode 
					AND istatus IN (0,1,2,3,4) 
					ORDER BY dtmovein DESC) > prev_ten.dtmoveout THEN (SELECT TOP 1 dtmovein+30 
																								FROM yardi_stage.dbo.tenant 
																								WHERE sunitcode=p.scode 
																								AND istatus IN (0,1,2,3,4) 
																								ORDER BY dtmovein DESC)
		ELSE GETDATE() 
	END) */ 
