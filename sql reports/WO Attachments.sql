SELECT DISTINCT 
top 1000
    [WO#] = wo.scode
	,[Property]  = p.scode
	,[WO Status] = wo.sstatus

	,[Attachment Type] =(CASE 
									WHEN d.hattachmenttype=48 then 'Estimate'
									WHEN d.hattachmenttype=49 then 'Inspection'
									WHEN d.hattachmenttype=50 then 'Photo'
									WHEN d.hattachmenttype=51 then 'Invoice'
									ELSE NULL
									END
									)
	,[Date] =d.dtdate  
	,[Description] = d.sdesc 
	    
FROM 
    yardi_stage.dbo.mm2wo wo 
        INNER JOIN yardi_stage.dbo.property p ON p.hmy = wo.hproperty
            LEFT JOIN yardi_stage.dbo.attributes at ON at.hprop=p.hmy  
        Left JOIN yardi_stage.dbo.pmdocs d on (d.hrecord=wo.hmy and  d.itype=25 )
        
      
WHERE
   at.subgroup12 not in  ('Corp')
and  wo.dtcall between '2015-01-01' and '2016-01-01'

ORDER by wo.scode

