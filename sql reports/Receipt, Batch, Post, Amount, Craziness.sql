USE Yardi_Stage;

SELECT

 [Prop Id] = u.scode
,[Instrument Number] = csd.schecknumber
,[Ctrl Number] = csd.hreceipt
,[Deleted?] = CASE WHEN csd.bdeleted = 0 THEN 0 ELSE 1 END
,[Receipt Date] = csd.dtreceived
,[Scan Date] = csd.dtcreated
,[Time Len Btw Scan & Receipt] = DATEDIFF(day,csd.dtreceived, csd.dtcreated)
,[Method of Pmt] = csd.sfilename
,[$ Amount] = csd.dcheckamount
,[Check Scanner] = pm.scode
,[Batch Number] = csd.hbatch
,[Batch Created By User] = pm2.scode
,[Batch Posted By User] = pm3.scode
,[Batch Creation Date] = csh.dtcreated
,[Batch Deposit Date] = csh.dtupdated

FROM checkscan_tenant cst


RIGHT JOIN checkscan_detail csd ON csd.hmy = cst.hcheck
LEFT JOIN checkscan_header csh ON csh.hmy = csd.hbatch 
LEFT JOIN pmuser pm ON pm.hmy = csd.hcreated
LEFT JOIN pmuser pm2 ON pm2.hmy = csh.hcreated
LEFT JOIN pmuser pm3 ON pm3.hmy = csh.hupdated
LEFT JOIN unit u ON u.hmy = cst.hunit

WHERE csd.dtcreated BETWEEN '2015-04-01' AND '2015-06-30'

-- AND csh.hcreated = csh.hupdated
-- AND DATEDIFF(day,csd.dtreceived, csd.dtcreated) >= 1