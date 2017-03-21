SELECT
[WO#] = wo.scode
,[WO Status] =  woh.sstatus
,[WO Reason] =  woh.sreason
,[WO Priority] =  woh.spriority
,[Notes] =  woh.sprioritynotes
,[Date] =  woh.dtusermodified
,[Updated By] = (SELECT uName from yardi_stage.dbo.pmUser where hmy=woh.hUsermodifiedby) 


FROM yardi_stage.dbo.mm2wo wo 
left join yardi_stage.dbo.wohistory woh on woh.hwo=wo.hmy 
where (woh.sstatus is not null or woh.sreason is not null or woh.spriority is not null or woh.sprioritynotes is not null or woh.dtusermodified is not null)
order by convert(int,wo.scode), woh.dtusermodified asc