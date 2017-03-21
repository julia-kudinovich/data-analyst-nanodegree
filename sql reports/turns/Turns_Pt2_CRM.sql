SELECT 

--Market, Division, 
	DISTINCT a.SUBGROUP12 as [Market]
	,a.SUBGROUP10 as 'Division'
	,a.SUBGROUP9 as 'District'
	,a.SUBGROUP18 as 'Region'
	
	--Number of Total Vacates Within Current Quarter
	,(SELECT count(c2.PropId) FROM CRM.dbo.construction c2
		INNER JOIN CRM.dbo.properties cp2 ON c2.PropId = cp2.PropId
			WHERE cp2.Market = a.SUBGROUP12 AND c2.name LIKE '%Tenant Turn%')


FROM Yardi_Stage.dbo.ATTRIBUTES a

WHERE a.SUBGROUP12 IS NOT NULL;