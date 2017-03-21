SELECT
	p.scode as 'Prop No.'
	,po.scode as 'PO No.'
--	,po.Sexptype as 'PO Type'
	,po.sOriginalsCode as '? OriginalCode ?'
	,po.dTranTotal '?Transaction Total?'
	,v.ucode 'Vendor Code'
	,v.ulastname 'Vendor Name'
	,d.sdesc 'PO Description' 
	,ac.sdesc 'Account Description'
	,d.hpayacct 'Account'
	,d.dtotalcost 'PO Total'
	,d.dunitprice 'Unit Cost'
	,d.dTranTotalCost '?Transaction Total?'
	
	--Look into the following row meanings
	,d.hpayrcd '?Payable Ref #?'
	,d.bclosed '? PO Complete ?'
	,po.dtClose '? Date PO Complete ?'
	,po.suser1 '?'
	
	--Get Status from wf_tran_step
	
	/*
	,(SELECT sstatus FROM Jobstatus 
			WHERE istatus = (SELECT TOP 1 iStatus FROM wf_tran_step WHERE iType = 26 AND hRecord = po.hMy ORDER BY hMy DESC))
	*/
	
	,(SELECT TOP 1 dtComplete FROM wf_tran_header WHERE iType = 26 AND hWf = 4 AND hRecord = po.hMy) as 'Complete Date'
	
	,a.SUBGROUP10 as 'Division'
	,a.SUBGROUP9 as 'District'
	,a.SUBGROUP18 as 'Region'
	,a.SUBGROUP12 as 'Market'
	,cp.Sqft

FROM mm2podet d
	
	INNER JOIN mm2po po ON po.hmy = d.hpo
	INNER JOIN property p ON p.HMY = d.hprop
	LEFT JOIN vendor v ON v.HMYPERSON = po.hvendor
	LEFT JOIN attributes a ON a.HPROP = p.HMY
	LEFT JOIN acct ac ON ac.HMY = d.hpayacct
	LEFT JOIN CRM.dbo.properties cp ON cp.PropId = p.scode
	
WHERE po.SEXPTYPE = 'Turn'
AND (SELECT TOP 1 dtComplete FROM wf_tran_header WHERE iType = 26 AND hWf = 4 AND hRecord = po.hMy) BETWEEN '2014-10-01' AND GETDATE()
;