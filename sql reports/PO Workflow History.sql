SELECT distinct  
[PO#] = convert(int,po.scode)
,[Workflow] = wfth.sname
,[Step] = wfs.sname
,[Status] =   (CASE 
						WHEN wfs.istatus=0 then 'Activated'
						WHEN wfs.istatus=1 then 'Started'
						WHEN wfs.istatus=4 then 'Canceled'
						WHEN wfs.istatus=6 then 'Completed'
						ELSE convert(varchar, wfs.istatus)
						END)
,[Approved By] = (SELECT uName from yardi_stage.dbo.pmUser where hmy=wfs.hUsercomplete)
,[Approval Notes] = wfs.snotes
,[Start Date] = wfs.dtstart
,[End Date] = wfs.dtcomplete
,[PO Amount] = po.dtotal 
FROM yardi_stage.dbo.mm2po po 
 left join yardi_stage.dbo.wf_tran_header wfth on (po.hmy = wfth.hrecord and wfth.iType=26)
LEFT JOIN yardi_stage.dbo.wf_tran_step wfs ON (wfs.htranheader = wfth.hmy AND wfs.itype = 26)


order by convert(int,po.scode), wfs.dtstart
