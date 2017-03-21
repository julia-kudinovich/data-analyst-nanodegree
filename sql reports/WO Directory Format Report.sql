SELECT DISTINCT
 [WO] = cast(rtrim(wo.scode) as int) 
,[Related WO] = wo.hrelwo 
,[Property] = p.scode 
,[Market] = rtrim(at.subgroup12)
,[Zip Code] = p.szipcode
,[Status] = wo.sstatus
,[Category] = wo.SCATEGORY 
,[Subcategory] = wo.SSUBCAT
,[WO Priority] = wo.spriority
,[WO Resolution] = wo.sResolution
,[Created By] = wo.SREQUESTEDBY
,[Problem Description] = wo.sprobdescnotes
,[Call Date] = wo.dtcall
,[Dispatched Date]  = wo.dtuser2
,[Follow-Up  Date]  = wo.dtuser3
,[Service Complete Date] = (SELECT TOP 1 dtusermodified FROM yardi_stage.dbo.wohistory WHERE hwo=wo.hmy AND sstatus='Service Complete' ORDER BY dtusermodified DESC)
,[Pending Invoice] = wo.dtuser5
,[Pending Payment] = (SELECT TOP 1 dtusermodified FROM yardi_stage.dbo.wohistory WHERE hwo=wo.hmy AND sstatus='Pending Payment' ORDER BY dtusermodified DESC)
,[Request Re-assignment] = wo.dtrequestreassignment
,[Vendor ID] = isnull(v.ucode, '')
,[Vendor Name] =  v.ulastname
,[Payable Batch] = CASE WHEN wo.hpayrcd>0 THEN wo.hpayrcd-1100000000  ELSE NULL END
,[Total Material Amount] = (SELECT sum(DPAYAMT) FROM yardi_stage.dbo.mm2wodet WHERE hwo = wo.hmy) 
,[Workflow Step] = (SELECT TOP 1 ws.sname FROM yardi_stage.dbo.wf_step ws LEFT JOIN yardi_stage.dbo.wf_tran_step_current wts ON wts.hstep=ws.hmy WHERE wts.htranheader= wfth.hmy) 
,[In-House Reassignment] = wo.suser3


FROM
    yardi_stage.dbo.mm2wo wo 
        INNER JOIN yardi_stage.dbo.property p 
            ON p.hmy = wo.hproperty
        LEFT JOIN yardi_stage.dbo.attributes at ON at.hprop=p.hmy  
        left outer join yardi_stage.dbo.vendor v 
            ON v.hmyperson = wo.hvendor
      
        LEFT JOIN yardi_stage.dbo.wf_tran_step wfs ON (wfs.hrecord = wo.hmy AND wfs.bcurrent = -1 AND wfs.itype = 25)
        OUTER APPLY (SELECT TOP 1 * FROM yardi_stage.dbo.wf_tran_header WHERE wo.hmy = hrecord AND iType=25 ORDER BY hmy DESC) wfth
 	
WHERE 1=1
 	AND at.subgroup12 NOT IN ('Corp')
	AND at.subgroup12 IS NOT NULL
	-- AND wo.dtcall >= '2016-01-01'
	
ORDER BY cast(rtrim(wo.scode) AS int)