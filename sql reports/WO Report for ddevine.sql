SELECT DISTINCT 
[Property]  = p.scode
,[District] =  RTRIM(at.subgroup9)
,[Market] = rtrim(at.subgroup12)
,[WO#] = wo.scode
,[WO Priority] = wo.spriority
,[WO Status] = wo.sstatus
,[WO Category] =  wo.SCATEGORY
,[WO Subcategory] =  wo.SSUBCAT
,[WO Brief Description] = wo.SBRIEFDESC
,[Call Date] = wo.dtcall
,[WO Schedule Date] = wo.dtsched
,[WO Complete Date] = wo.dtwcompl
,[Material Amount] = (SELECT sum(DQUAN) from  yardi_stage.dbo.mm2wodet  where hwo = wo.hmy )
,[Total payable Amount] =  (SELECT sum(DPAYAMT) from  yardi_stage.dbo.mm2wodet  where hwo = wo.hmy )
,[Superintendent] = cp.superassigned
,[Turn/Rehab] = (Select top 1 sexptype from yardi_stage.dbo.mm2po po LEFT JOIN yardi_stage.dbo.mm2podet d ON po.hmy = d.hpo where p.hmy=d.hprop and po.sexptype in ('Turn', 'Rehab') order by CONVERT(date,po.dtordereddate) desc )
,[Certified Date] = cp.certificationdate
,[Tenant ID] = t.scode
,[Move In] = t.dtmovein
,[Move Out] = t.dtmoveout
,[Market Ready Date] = (SELECT TOP 1 CONVERT(date, start) 
   								FROM   [crm].[dbo].[constructionhistory] 
   								WHERE p.scode LIKE LEFT(NAME, 7) AND constructionstatus = 'Market Ready' 
   								ORDER  BY start DESC)
,[Rent Ready Date] =cp.currentrentready
,[Most recent Tenant] = (SELECT top 1 scode from yardi_stage.dbo.tenant where hproperty=wo.hproperty and istatus in (0,1,2,3,4)  order by dtmovein desc  )
,[Most recent Move in] =  (SELECT top 1 dtmovein from yardi_stage.dbo.tenant where hproperty=wo.hproperty and istatus in (0,1,2,3,4)  order by dtmovein desc  )

FROM  yardi_stage.dbo.mm2wo wo 
INNER JOIN yardi_stage.dbo.property p ON p.hmy = wo.hproperty
LEFT JOIN yardi_stage.dbo.tenant t ON t.hmyperson = wo.htenant
LEFT JOIN yardi_stage.dbo.attributes at ON at.hprop=p.hmy    
OUTER APPLY (SELECT TOP 1 * FROM crm.dbo.properties where propid=p.scode) cp
    
WHERE  wo.sstatus NOT IN ('Cancelled', 'Canceled')
AND (SELECT sum(DPAYAMT) from  yardi_stage.dbo.mm2wodet  where hwo = wo.hmy ) >0
AND wo.dtcall between  '2016-01-01' and '2016-07-09' 
AND RTRIM(at.subgroup9) in ('San Antonio') -- district 
	
ORDER BY 10
