SElECT DISTINCT
	 [Tenant ID] = t.scode
	,[Tenant Status] = (SELECT status FROM yardi_stage.dbo.tenstatus WHERE istatus=t.istatus)
	,[Last Name] = t.slastname
	,[First Name] =  t.sfirstname
	,[Propert ID] = p.scode
	,[Number of WO (including canceled)] = (SELECT COUNT (DISTINCT scode) FROM mm2wo WHERE htenant=t.hmyperson)
	,[Number of WO (excluding canceled)] = (SELECT SUM(CASE WHEN sstatus!='Canceled' THEN 1 ElSE 0 END) FROM mm2wo WHERE htenant=t.hmyperson)
	,[Total Sum of Charges (excluding canceled WO)] = (SELECT SUM(CASE WHEN sstatus!='Canceled' THEN ctotal0 ELSE 0 END) FROM mm2wo WHERE htenant=t.hmyperson)
	,[WO #] = CONVERT(INTEGER, wo.scode)
	,[Date Created] = wo.dtcall
	,[Status] = wo.sstatus
	,[Category] = wo.SCATEGORY
	,[Subcategory] =  wo.SSUBCAT
	,[Brief Description] = wo.SBRIEFDESC
	,[Problem Description] = wo.sprobdescnotes
	,[Total quantity of Materials] = (SELECT SUM(dquan) FROM mm2wodet WHERE hwo=wo.hmy )
	,[Total WO Cost] =  wo.ctotal0

FROM tenant t

	LEFT JOIN mm2wo wo ON wo.htenant=t.hmyperson
	INNER JOIN property p ON p.hmy = wo.hproperty
	LEFT JOIN attributes at ON at.hprop=p.hmy  
	LEFT JOIN mm2wodet wod ON wod.hwo = wo.hmy
            
   WHERE 1=1
   AND t.istatus in (0,3,4)
	AND p.scode IN ('')            
ORDER BY  t.scode      