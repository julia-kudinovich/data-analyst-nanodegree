select distinct 
dp.scode 'Property',
u.sstatus 'Unit Status',
rtrim(at.subgroup10) 'Division', rtrim(at.subgroup18) 'Region', rtrim(at.subgroup9) 'District', rtrim(at.subgroup12) 'Market',
RTRIM(at.SUBGROUP13) [Market Area],
rtrim((SELECT at2.spropname FROM yardi_stage.dbo.attributes at2 WHERE at.subgroup14 = at2.scode)) Entity,
dp.SADDR1 Address,
dp.SCITY City,
dp.SSTATE State,
dp.SZIPCODE ZIP,
CAST(rtrim(ltrim(cp.Latitude)) as DECIMAL(14,10)) Latitude,
CAST(rtrim(ltrim(cp.Longitude)) as DECIMAL(14,10)) Longitude,
u.DSQFT SQFT,
cp.Bedrooms,
ROUND(CAST(cp.Baths AS float), 1) Baths,

convert(date,(select certificationdate from crm.dbo.properties where propid=dp.scode)) 'Certification date',
rr.start 'Rent Ready Date',
cp.constructionlifecycle as 'Lifecycle' ,
   
convert(date,prev_ten.dtmoveout)'Last Move out Date',

po.scode 'PO #', 
d.hmy 'PO Line Item',
convert(date,po.dtordereddate) 'Order Date', 
po.dtscheddeldate,
po.dtactdeldate 'Received Date',
po.dtreqdate 'Required By Date',
po.dtdatein,
po.dtdatemodified,
po.dtclose, 
case when datediff(day, po.dtreqdate, case when po.dtactdeldate is null then getdate() else po.dtactdeldate end)<1 then 0
else  datediff(day, po.dtreqdate, case when po.dtactdeldate is null then getdate() else po.dtactdeldate end)
end 'Days Overdue (Received or Current Date-Required By Date)',

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
(select sdesc from yardi_stage.dbo.acct where hmy=d.hpayacct) 'GL Actt Desc',

case d.bclosed when 0 then 'Open' else 'Closed' end  'Status',
case	when yardi_stage.dbo.ApprChk_PayScan (po.hmy) = 1 then 1	else 0	end 'Payable Approved' ,
case wfth.istatus when 0 then 'In Process' when 1 then 'Completed' when 2 then 'Cancelled' when 3 then 'Rejected' else '' end  'Approval Status',
(select top 1 ws.sname from yardi_stage.dbo.wf_step ws left join yardi_stage.dbo.wf_tran_step_current wts on wts.hstep=ws.hmy  where wts.htranheader= wfth.hmy) 'Approval Step'
	
FROM 
yardi_stage.dbo.mm2po po
left outer join yardi_stage.dbo.mm2podet d on po.hmy = d.hpo
inner join yardi_stage.dbo.property dp on d.hprop = dp.hmy
left join [crm].[dbo].[properties] cp on cp.propid=dp.scode
left join yardi_stage.dbo.mm2stock ms on ms.hmy = d.hstock
left outer join yardi_stage.dbo.unit u on dp.hmy = u.hproperty
left join yardi_stage.dbo.acct ac on ac.hmy=d.hpayacct
left outer join yardi_stage.dbo.person mv on mv.hmy = po.hvendor
      INNER JOIN yardi_stage.dbo.wf_tran_header wfth ON  (po.hmy = wfth.hrecord and wfth.iType=26)
      LEFT JOIN yardi_stage.dbo.attributes at ON at.hprop = dp.hmy 
Outer Apply (select top 1 * from yardi_stage.dbo.tenant where sunitcode=dp.scode order by dtmoveout desc) prev_ten      
OUTER APPLY (SELECT TOP 1 *  FROM CRM.dbo.constructionhistory WHERE Name =CONCAT(dp.SCODE, '- Rent Ready')  ORDER BY Start DESC) rr
     
where rtrim((select subgroup12 from yardi_stage.dbo.attributes where scode=dp.scode)) not in ('Corp')
and rtrim((select subgroup12 from yardi_stage.dbo.attributes where scode=dp.scode)) is not null
and u.sstatus not in ('Down', 'Excluded')
and  wfth.istatus  not in (2,3) -- not cancelled or rejected
and po.sexptype in ('Rehab', 'Turn')
and d.bclosed=0 -- only open po's
 
