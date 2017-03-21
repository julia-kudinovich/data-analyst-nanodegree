SElECT DISTINCT
	 [Tenant ID] = t.scode
	,[Tenant Status] = (SELECT status FROM yardi_stage.dbo.tenstatus WHERE istatus=t.istatus)
	,[Last Name] = t.slastname
	,[First Name] =  t.sfirstname
	,[Propert ID] = p.scode
	,[Number of WO (including canceled)] = (SELECT COUNT (DISTINCT scode) FROM yardi_stage.dbo.mm2wo WHERE htenant=t.hmyperson)
	,[Number of WO (excluding canceled)] = (SELECT SUM(CASE WHEN sstatus!='Canceled' THEN 1 ElSE 0 END) FROM yardi_stage.dbo.mm2wo WHERE htenant=t.hmyperson)
	,[Total Sum of Charges (excluding canceled WO)] = (SELECT SUM(CASE WHEN sstatus!='Canceled' THEN ctotal0 ELSE 0 END) FROM yardi_stage.dbo.mm2wo WHERE htenant=t.hmyperson)
	,[WO #] = CONVERT(INTEGER, wo.scode)
	,[Date Created] = wo.dtcall
	,[Status] = wo.sstatus
	,[Category] = wo.SCATEGORY
	,[Subcategory] =  wo.SSUBCAT
	,[Brief Description] = wo.SBRIEFDESC
	,[Problem Description] = wo.sprobdescnotes
	,[Total quantity of Materials] = (SELECT SUM(dquan) FROM yardi_stage.dbo.mm2wodet WHERE hwo=wo.hmy )
	,[Total WO Cost] =  wo.ctotal0

FROM yardi_stage.dbo.tenant t

	LEFT JOIN yardi_stage.dbo.mm2wo wo ON wo.htenant=t.hmyperson
	INNER JOIN yardi_stage.dbo.property p ON p.hmy = wo.hproperty
	LEFT JOIN yardi_stage.dbo.attributes at ON at.hprop=p.hmy  
	LEFT JOIN yardi_stage.dbo.mm2wodet wod ON wod.hwo = wo.hmy
            
   WHERE  1=1
   	AND t.istatus in (0,3,4) -- current, notice, eviction 
	AND p.scode IN ('')            
	ORDER BY  5;

SELECT  	 
	 [Tenant Code] = t.scode
	,[Last Name] =  t.slastname
	,[Status] =  ts.status
	,[Prop ID] =  u.scode
	,[# of Phone Calls] =  (select count(distinct created_on) from crm.dbo.phonecalls where regarding=u.scode and created_on>=t.dtmovein and (description like '%resident%' or description like '%tenant%' or description like '%t.slastname%'))
	,[Created On] = pc.created_on
	,[Category] =  pc.category
	,[Sub Category] =  pc.sub_category
	,[Subject] = pc.subject
	,[Description] =  pc.description
FROM yardi_stage.dbo.unit u 
INNER JOIN  yardi_stage.dbo.tenant t ON u.hmy=t.hunit  and t.istatus IN (0,3,4) -- current, notice, eviction 
INNER JOIN yardi_stage.dbo.tenstatus ts ON ts.istatus=t.istatus
INNER JOIN crm.dbo.phonecalls pc ON pc.regarding=u.scode 

WHERE 1=1
AND u.scode  IN ('')
AND (pc.description like '%resident%' or pc.description like '%tenant%' or pc.description like '%t.slastname%')
AND pc.created_on>=t.dtmovein
ORDER BY 4 asc, 6 desc;