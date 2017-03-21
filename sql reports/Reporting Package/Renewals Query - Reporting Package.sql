USE Yardi_Stage;

SELECT u.scode 'Prop ID'
	,u.sstatus 'Unit Status'
	,rtrim(a.subgroup12) 'Market'
	,t.scode 'Tenant Code'
	,(
		SELECT STATUS
		FROM tenstatus
		WHERE istatus = t.istatus
		) 'Tenant Status'
	,lh.dtleasefrom 'Old Lease From'
	,lh.dtleaseto 'Old Lease To'
	,t.dtmoveout 'Move Out Date'
	,(CASE 
		WHEN 
			(SELECT TOP 1 th.dtoccurred 
			FROM tenant_history th
			WHERE lh.htent = th.htent	
			AND th.sevent = 'Lease Renewal Canceled'
			ORDER BY th.dtoccurred DESC) >
			 
			(SELECT TOP 1 th.dtoccurred 
			FROM tenant_history th
			WHERE lh.htent = th.htent	
			AND th.sevent = 'Lease Renewal'
			ORDER BY th.dtoccurred DESC)
			
			THEN NULL
			
		ELSE 
			(SELECT TOP 1 th.dtoccurred 
			FROM tenant_history th
			WHERE lh.htent = th.htent	
			AND th.sevent = 'Lease Renewal'
			ORDER BY th.dtoccurred DESC)
		END) 'Lease Renewal Date'
		
	,(CASE 
		WHEN
			(SELECT TOP 1 th.dtoccurred
			FROM tenant_history th
			WHERE lh.htent = th.htent
			AND th.sevent = 'Lease Renewal'
			ORDER BY th.dtoccurred DESC) <
			
			(SELECT TOP 1 th.dtoccurred
			FROM tenant_history th
			WHERE lh.htent = th.htent
			AND th.sevent = 'Lease Renewal Canceled'
			ORDER BY th.dtoccurred DESC)
			
				THEN NULL 
				
			ELSE
				(SELECT TOP 1 th.dtleasefrom
				FROM tenant_history th
				WHERE lh.htent = th.htent
				AND th.sevent = 'Lease Renewal'
				ORDER BY th.dtoccurred DESC)
		
		END) 'New Lease Date From'
		
	,(CASE 
		WHEN
			(SELECT TOP 1 th.dtoccurred
			FROM tenant_history th
			WHERE lh.htent = th.htent
			AND th.sevent = 'Lease Renewal'
			ORDER BY th.dtoccurred DESC) <
			
			(SELECT TOP 1 th.dtoccurred
			FROM tenant_history th
			WHERE lh.htent = th.htent
			AND th.sevent = 'Lease Renewal Canceled'
			ORDER BY th.dtoccurred DESC)
			
				THEN NULL 
				
			ELSE
				(SELECT TOP 1 th.dtleaseto
				FROM tenant_history th
				WHERE lh.htent = th.htent
				AND th.sevent = 'Lease Renewal'
				ORDER BY th.dtoccurred DESC)
		
		END) 'New Lease Date To'		
	,DATEDIFF(DAY,(CASE 
		WHEN
			(SELECT TOP 1 th.dtoccurred
			FROM tenant_history th
			WHERE lh.htent = th.htent
			AND th.sevent = 'Lease Renewal'
			ORDER BY th.dtoccurred DESC) <
			
			(SELECT TOP 1 th.dtoccurred
			FROM tenant_history th
			WHERE lh.htent = th.htent
			AND th.sevent = 'Lease Renewal Canceled'
			ORDER BY th.dtoccurred DESC)
			
				THEN NULL 
				
			ELSE
				(SELECT TOP 1 th.dtleasefrom
				FROM tenant_history th
				WHERE lh.htent = th.htent
				AND th.sevent = 'Lease Renewal'
				ORDER BY th.dtoccurred DESC)
		
		END), (CASE 
		WHEN
			(SELECT TOP 1 th.dtoccurred
			FROM tenant_history th
			WHERE lh.htent = th.htent
			AND th.sevent = 'Lease Renewal'
			ORDER BY th.dtoccurred DESC) <
			
			(SELECT TOP 1 th.dtoccurred
			FROM tenant_history th
			WHERE lh.htent = th.htent
			AND th.sevent = 'Lease Renewal Canceled'
			ORDER BY th.dtoccurred DESC)
			
				THEN NULL 
				
			ELSE
				(SELECT TOP 1 th.dtleaseto
				FROM tenant_history th
				WHERE lh.htent = th.htent
				AND th.sevent = 'Lease Renewal'
				ORDER BY th.dtoccurred DESC)
		
		END)) 'Length of New Lease'
	
,[New Recurring Rent] = ISNULL((SELECT TOP 1 destimated FROM camrule WHERE htenant = lh.htent AND hchargecode = 10 AND dtfrom > lh.dtleaseto  ORDER BY dtfrom ASC),0) + ISNULL((SELECT TOP 1 destimated FROM camrule WHERE htenant = lh.htent AND hchargecode = 11 AND dtfrom > lh.dtleaseto  ORDER BY dtfrom ASC),0) + ISNULL((SELECT TOP 1 destimated FROM camrule WHERE htenant = lh.htent AND hchargecode = 18 AND dtfrom > lh.dtleaseto  ORDER BY dtfrom ASC),0) +       ISNULL((SELECT TOP 1 destimated FROM camrule WHERE htenant = lh.htent AND hchargecode = 20 AND dtfrom > lh.dtleaseto  ORDER BY dtfrom ASC),0)
	
,[New Charged Rent] = ISNULL((SELECT TOP 1 stotalamount FROM trans WHERE hperson = lh.htent AND hoffsetacct = 1335 AND upostdate > lh.dtleaseto),0) + ISNULL((SELECT TOP 1 stotalamount FROM trans WHERE hperson = lh.htent AND hoffsetacct = 1327 AND upostdate > lh.dtleaseto),0) + ISNULL((SELECT TOP 1 stotalamount FROM trans WHERE hperson = lh.htent AND hoffsetacct = 2127 AND upostdate > lh.dtleaseto),0)	

,[Old Recurring Rent] = ISNULL((SELECT TOP 1 destimated FROM camrule WHERE htenant = lh.htent AND hchargecode = 10 AND dtfrom < lh.dtleaseto  ORDER BY dtfrom DESC),0) + ISNULL((SELECT TOP 1 destimated FROM camrule WHERE htenant = lh.htent AND hchargecode = 11 AND dtfrom < lh.dtleaseto  ORDER BY dtfrom DESC),0) + ISNULL((SELECT TOP 1 destimated FROM camrule WHERE htenant = lh.htent AND hchargecode = 18 AND dtfrom < lh.dtleaseto ORDER BY dtfrom DESC),0) +    ISNULL((SELECT TOP 1 destimated FROM camrule WHERE htenant = lh.htent AND hchargecode = 20 AND dtfrom < lh.dtleaseto  ORDER BY dtfrom DESC),0)

,[Old Charged Rent] = ISNULL((
		SELECT TOP 1 stotalamount
		FROM trans
		WHERE hperson = lh.htent
			AND hoffsetacct = 1335
			AND upostdate = datefromparts(year(dateadd(m, - 1, lh.dtleaseto)), month(dateadd(m, - 1, lh.dtleaseto)), 1)
		ORDER BY upostdate DESC
		),0) + ISNULL((
		SELECT TOP 1 stotalamount
		FROM trans
		WHERE hperson = lh.htent
			AND hoffsetacct = 1327
			AND upostdate = datefromparts(year(dateadd(m, - 1, lh.dtleaseto)), month(dateadd(m, - 1, lh.dtleaseto)), 1)
		ORDER BY upostdate DESC
		),0) + ISNULL((
		SELECT TOP 1 stotalamount
		FROM trans
		WHERE hperson = lh.htent
			AND hoffsetacct = 2127
			AND upostdate = datefromparts(year(dateadd(m, - 1, lh.dtleaseto)), month(dateadd(m, - 1, lh.dtleaseto)), 1)
		ORDER BY upostdate DESC
		),0)	

,t.bmtm as 'MTM?',

MONTH(lh.dtleaseto) 'Month Expired',
Year(lh.dtleaseto) 'Year Expired'
, lh.htent
FROM lease_history lh

LEFT JOIN tenant t ON t.hmyperson = lh.htent
LEFT JOIN attributes a ON a.hprop = t.hproperty
LEFT JOIN unit u ON u.hproperty = t.hproperty

WHERE lh.dtleaseto >= '2015-04-01'
AND lh.dtleaseto < '2015-06-01' 
AND lh.iinactiveproposal IS NULL