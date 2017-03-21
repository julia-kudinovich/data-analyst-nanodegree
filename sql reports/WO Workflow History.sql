SELECT distinct  
[WO#] = convert(int,wo.scode)
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
FROM yardi_stage.dbo.mm2wo wo 
 left join yardi_stage.dbo.wf_tran_header wfth on (wo.hmy = wfth.hrecord and wfth.iType=25)
LEFT JOIN yardi_stage.dbo.wf_tran_step wfs ON (wfs.htranheader = wfth.hmy AND wfs.itype = 25)


order by convert(int,wo.scode), wfs.dtstart
