SELECT DISTINCT
 [WO] = cast(rtrim(wo.scode) as int) 
,[Property] = p.scode 
,[Market] = rtrim(at.subgroup12)
,[Status] = wo.sstatus
,[Category] = wo.SCATEGORY 
,[Subcategory] = wo.SSUBCAT
,[WO Resolution] = wo.sResolution
,[Created By] = wo.SREQUESTEDBY
,[Problem Description] = wo.sprobdescnotes
,[Call Date] = wo.dtcall
,[Dispatched Date]  = wo.dtuser2
,[Follow-Up  Date]  = wo.dtuser3
,[Service Complete Date] = wo.dtwcompl
,[Pending Invoice] = wo.dtuser5
,[Pending Payment] = (SELECT top 1 dtusermodified FROM yardi_stage.dbo.wohistory where hwo=wo.hmy and sstatus='Pending Payment' order by dtusermodified desc)
,[Request Re-assignment] = wo.dtrequestreassignment

,isnull(v.ucode, '') 'Vendor ID', v.ulastname 'Vendor Name',
case when wo.hpayrcd>0 then  wo.hpayrcd-1100000000  else null end 'Payable Batch #',
case when wo.hchgrcd>0 then wo.hchgrcd-1600000000 else null end 'Charge Batch #',
(select count(hmy) from yardi_stage.dbo.pmdocs where hrecord=wo.hmy and itype=25 ) 'Attachment',
 isnull(wos.scode, '') 'Item Type', wod.SDESC 'Description', wod.DQUAN 'Quantity', wod.DUNITPRICE 'Unit Pay', wod.DPAYAMT 'Pay Total',
[Unit Charge] = wod.dchgunitprice
,[Charge Total] = wod.dchgamt
,[GL Pay Account Code] = (SELECT scode FROM yardi_stage.dbo.acct WHERE hmy=wod.hpayacct)
,[GL Pay Account Description] = (SELECT sdesc FROM yardi_stage.dbo.acct WHERE hmy=wod.hpayacct)
,case when wod.bdetpay=-1 then 'Checked' else 'Unchecked' end 'Pay Box Checked/Unchecked'
,case when wod.bdetchg=-1 then 'Checked' else 'Unchecked' end 'Charge Box Checked/Unchecked'
,[Workflow Step] = (SELECT TOP 1 ws.sname FROM yardi_stage.dbo.wf_step ws LEFT JOIN yardi_stage.dbo.wf_tran_step_current wts ON wts.hstep=ws.hmy WHERE wts.htranheader= wfth.hmy) 

from
    mm2wo wo 
        inner join property p 
            on p.hmy = wo.hproperty
        left outer join tenant t
            on t.hmyperson = wo.htenant
        left outer join unit u 
            on u.hmy = wo.hunit
        left join attributes at on at.hprop=u.hproperty    
        left outer join vendor v 
            on v.hmyperson = wo.hvendor
      
        LEFT JOIN yardi_stage.dbo.wf_tran_step wfs ON (wfs.hrecord = wo.hmy AND wfs.bcurrent = -1 AND wfs.itype = 25)
        left outer join mm2wodet wod 
            on wod.hwo = wo.hmy
        left outer join mm2stock wos 
            on wos.hmy = wod.hstock
             	OUTER APPLY (SELECT TOP 1 * FROM yardi_stage.dbo.wf_tran_header where wo.hmy = hrecord and iType=25 order by hmy desc) wfth
 	
where
   at.subgroup12 not in ('Corp')
	and at.subgroup12  is not null

order by cast(rtrim(wo.scode) as int)