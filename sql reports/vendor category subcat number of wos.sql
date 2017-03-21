SELECT DISTINCT 

	[Vendor ID] = v.ucode
	,[Vendor Name] = v.ulastname
	,[Vendor Type] =  v.sfields4
	,[Acitve/Ianctive] = (CASE WHEN v.binactive=1 THEN 'INCATIVE' ELSE 'ACTIVE' END)
	,[WO Category] =  wo.SCATEGORY
	,[WO Subcategory] =  wo.SSUBCAT
	,[# of WOs] = (SELECT COUNT( *) from mm2wo where hvendor=v.hmyperson and sstatus!='Canceled')
	,[# of WOs In Progress] = (SELECT COUNT(*) from mm2wo where hvendor=v.hmyperson and sstatus='In Progress')
	    
FROM 
    yardi_stage.dbo.mm2wo wo 
        INNER JOIN yardi_stage.dbo.property p ON p.hmy = wo.hproperty
        LEFT JOIN yardi_stage.dbo.tenant t ON t.hmyperson = wo.htenant
        LEFT JOIN yardi_stage.dbo.attributes at ON at.hprop=p.hmy    
        LEFT JOIN yardi_stage.dbo.vendor v ON v.hmyperson = wo.hvendor
        LEFT JOIN yardi_stage.dbo.wf_tran_header wfth ON (wfth.hrecord = wo.hmy AND wfth.itype = 25)
        LEFT JOIN yardi_stage.dbo.wf_tran_step wfs ON (wfs.hrecord = wo.hmy AND wfs.bcurrent = -1 AND wfs.itype = 25)
        LEFT JOIN yardi_stage.dbo.mm2wodet wod ON wod.hwo = wo.hmy
        LEFT JOIN yardi_stage.dbo.mm2stock wos ON wos.hmy = wod.hstock
        LEFT JOIN yardi_stage.dbo.pmUser au ON wfs.hUserComplete = au.hMy
		--  OUTER APPLY (SELECT TOP 1 * FROM yardi_stage.dbo.tenant WHERE sunitcode=p.scode ORDER BY dtmoveout DESC) prev_ten  	
WHERE
   at.subgroup12 NOT IN ('Corp')
	AND at.subgroup12  IS NOT NULL
	
and v.ucode is not null
and v.ucode!='Ah4r'
and wo.sstatus!='Canceled'
-- and v.binactive=1

order by v.ucode