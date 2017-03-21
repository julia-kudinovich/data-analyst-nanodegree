select distinct
    wo.scode 'WO#', wod.hmy 'WO Line Item', p.scode Property, u.sstatus 'Current Unit Status',
	 rtrim(at.subgroup10) as 'Division', rtrim(at.subgroup18) as 'Region', rtrim(at.subgroup9) as 'District', rtrim(at.subgroup12) as 'Market',
convert(date,(select certificationdate from crm.dbo.properties where propid=p.scode)) 'Certification date',
(SELECT TOP 1 CONVERT(date, start) 
   FROM   [crm].[dbo].[constructionhistory] 
   WHERE p.scode LIKE LEFT(NAME, 7) AND constructionstatus = 'Rent Ready' 
   ORDER  BY start DESC) AS 'Rent Ready Date',
   
	t.scode 'Tenant ID',
	t.dtleasefrom 'Lease From',
	t.dtleaseto 'Lease To',
	t.dtmovein 'Move in',
	t.dtmoveout 'Move out', 
   
    isnull(v.ucode, '') 'Vendor ID', v.ulastname 'Vendor Name', 
    wo.spriority Priority, wo.sstatus Status, wo.SCATEGORY Category, wo.SSUBCAT Subcategory, wo.sfulldesc 'Full Description',  wo.sResolution Resolution,  wo.scallername 'Caller Name',
    wo.dtcall 'Call Date',  wo.dtdue 'Schedule Date', wo.dtwcompl 'Complete Date',
    
    ps.ucode 'Employee', wo.SREQUESTEDBY 'Created User', wo.DTDATEIN 'Created date', wo.SUPDATEDBY 'Updated User', wo.DTUPDATEDT 'Updated Date',
    au.uName  'Approved By', wfs.dtComplete 'Date Approved', wo.dtinvoice, 
    
 isnull(wos.scode, '') 'Stock', wod.SDESC 'Stock Description', wod.DQUAN 'Quantity', wod.DUNITPRICE 'Unit Price', wod.DPAYAMT 'Total',
(select scode from yardi_stage.dbo.acct where hmy=wod.hpayacct) 'GL Actt Code',
(select sdesc from yardi_stage.dbo.acct where hmy=wod.hpayacct) 'GL Actt Desc'
    
from
    yardi_stage.dbo.mm2wo wo 
        inner join yardi_stage.dbo.property p 
            on p.hmy = wo.hproperty
        left outer join yardi_stage.dbo.tenant t 
            on t.hmyperson = wo.htenant
        left outer join yardi_stage.dbo.unit u 
            on u.hmy = wo.hunit
        left join yardi_stage.dbo.attributes at on at.hprop=u.hproperty    
        left outer join yardi_stage.dbo.vendor v 
            on v.hmyperson = wo.hvendor
        left outer join yardi_stage.dbo.mmasset a 
            on a.hmy = wo.hasset
       left outer join yardi_stage.dbo.wf_tran_header wfh 
            on (wfh.hrecord = wo.hmy
	    and wfh.itype = 25)
        left outer join yardi_stage.dbo.wf_tran_step wfs
            on (wfs.hrecord = wo.hmy
            and wfs.bcurrent = -1
	    and wfs.itype = 25)
        left outer join yardi_stage.dbo.mm2wodet wod 
            on wod.hwo = wo.hmy
        left outer join yardi_stage.dbo.mm2stock wos 
            on wos.hmy = wod.hstock
        left outer join yardi_stage.dbo.acct pa 
            on pa.hmy = wod.hpayacct
        left outer join yardi_stage.dbo.chargtyp ct 
            on ct.hmy = wod.hchgcode
            left outer join yardi_stage.dbo.pmUser au on 
		wfs.hUserComplete = au.hMy
		left outer join yardi_stage.dbo.Person ps on wod.hPerson = ps.hMy
		

where
    p.itype = 3
    and wo.sstatus!='Canceled'
   and at.subgroup12 not in ('Corp')
	and at.subgroup12  is not null

