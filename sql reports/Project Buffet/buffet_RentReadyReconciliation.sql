select distinct 
dp.scode 'Property', 
u.sstatus 'Unit Status',
rtrim(at.subgroup10)'Division', 
rtrim(at.subgroup18) 'Region', 
rtrim(at.subgroup9) 'District', 
rtrim(at.subgroup12) 'Market',
rtrim((SELECT at2.spropname FROM yardi_stage.dbo.attributes at2 WHERE at.subgroup14 = at2.scode)) 'Entity',
CAST(rtrim(ltrim(cp.Latitude)) as DECIMAL(14,10)) Latitude,
CAST(rtrim(ltrim(cp.Longitude)) as DECIMAL(14,10)) Longitude,

convert(date,(select certificationdate from crm.dbo.properties where propid=dp.scode)) 'Certification date',
(case when (mr.enddate>rr.start or rr.start is null) then mr.enddate else rr.start end) 'RR Date',

convert(date,prev_ten.dtmoveout )'Last Move out Date',

po.scode 'PO #', 
d.hmy 'PO Line Item ID',   
convert(date,po.dtordereddate) 'Order Date', 
po.dtreqdate 'Required By Date',
po.dtactdeldate 'Received Date',

mv.ulastname 'Vendor Name',
d.sdesc 'Item Description', 
ms.scode 'Item Code',
case	when d.iqtyreceived <> 0 then 
		d.iqtyreceived 
	else 
		d.iqtyordered 
	end 'Quantity',
d.dunitprice 'Unit Price', 
d.dtotalcost  'Cost',
po.dtotal 'Total PO Cost',
po.sexptype 'Expense Type',
po.srequestedby 'Requestor',

stuff((select top 1  hpayable from yardi_stage.dbo.glinvregTrans where hmy=(select top 1  hinvorrec from yardi_stage.dbo.glinvregdetail where hpodet=d.hmy) order by sdateoccurred desc),1,3,'') 'Payable Ctrl#',
(select top 1 hinvorrec from yardi_stage.dbo.glinvregdetail where hpodet=d.hmy ) 'IR Ctrl#',
(select scode from yardi_stage.dbo.acct where hmy=d.hpayacct) 'GL Actt Code',
(select sdesc from yardi_stage.dbo.acct where hmy=d.hpayacct) 'GL Actt Descr',

case d.bclosed when 0 then 'Open' else 'Closed' end  'Status',
case wfth.istatus when 0 then 'In Process' when 1 then 'Completed' when 2 then 'Cancelled' when 3 then 'Rejected' else '' end  'Approval Status',
(select top 1 ws.sname from yardi_stage.dbo.wf_step ws left join yardi_stage.dbo.wf_tran_step_current wts on wts.hstep=ws.hmy  where wts.htranheader= wfth.hmy) 'Approval Step',
case	when yardi_stage.dbo.ApprChk_PayScan (po.hmy) = 1 then 1	else 0	end 'Payable Approved' ,
	
prev_ten.scode ' Last Tenant Id',
(select count(distinct hmy) from yardi_stage.dbo.tenant_history where htent=prev_ten.hmyperson and sevent='Eviction') 'Times Went Into Evictions',
(select count(sevent) from yardi_stage.dbo.tenant_history where sevent='Lease Renewal' and htent=prev_ten.hmyperson)-(select count(sevent) from yardi_stage.dbo.tenant_history where sevent='Lease Renewal Canceled' and htent=prev_ten.hmyperson) '# of Renewals'

FROM 
yardi_stage.dbo.mm2po po
left outer join yardi_stage.dbo.mm2podet d on po.hmy = d.hpo
inner join yardi_stage.dbo.property dp on d.hprop = dp.hmy
left join [crm].[dbo].[properties] cp on cp.propid=dp.scode
left join yardi_stage.dbo.mm2stock ms on ms.hmy = d.hstock
left outer join yardi_stage.dbo.unit u on dp.hmy = u.hproperty
left join yardi_stage.dbo.acct ac on ac.hmy=d.hpayacct
left outer join yardi_stage.dbo.person mv on mv.hmy = po.hvendor
      INNER JOIN yardi_stage.dbo.wf_tran_header wfth ON (po.hmy = wfth.hrecord and wfth.iType=26)
      LEFT JOIN yardi_stage.dbo.attributes at ON at.hprop = dp.hmy 
outer apply (select top 1 * from yardi_stage.dbo.tenant where sunitcode=dp.scode  order by dtmoveout desc) prev_ten
OUTER APPLY (SELECT TOP 1 *  FROM CRM.dbo.constructionhistory WHERE Name =CONCAT(dp.SCODE, '- Rent Ready')  ORDER BY Start DESC) rr
OUTER APPLY (SELECT TOP 1 *  FROM CRM.dbo.constructionhistory WHERE Name =CONCAT(dp.SCODE, '- Market Ready') ORDER BY enddate DESC) mr
     
where wfth.istatus in (0,1)
and rtrim((select subgroup12 from yardi_stage.dbo.attributes where scode=dp.scode)) not in ('Corp')
and rtrim((select subgroup12 from yardi_stage.dbo.attributes where scode=dp.scode)) is not null

and po.dtordereddate  >=(case when (mr.enddate>rr.start or rr.start is null) then mr.enddate else rr.start end) 
and po.dtordereddate  >= (case when prev_ten.dtmoveout is not null then prev_ten.dtmoveout else '1900-01-01' end) -- for the case when there is no rr or mr date after last move out date but unit status indicates ready

and u.sStatus IN ('Vacant rented Ready', 'Vacant Unrented Ready') 
AND NOT EXISTS (SELECT ISTATUS FROM  Yardi_Stage.dbo.TENANT WHERE  (SUNITCODE = u.SCODE) AND ISTATUS = 2)
