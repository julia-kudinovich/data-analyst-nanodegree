USE [PM]
GO

/****** Object:  View [dbo].[uvwPropertyCategory]    Script Date: 6/15/2015 5:06:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[uvwPropertyCategory]
AS
SELECT [Prop ID] = u.scode, [Prop Status] = u.sstatus, [Division] = rtrim(at.subgroup10), [Region] = rtrim(at.subgroup18), [District] = rtrim(at.subgroup9), [Market] = rtrim(at.subgroup12), [Market Area] = rtrim(at.subgroup13), [Entity] = rtrim((
			SELECT at2.spropname
			FROM Yardi_stage.dbo.attributes at2
			WHERE at.subgroup14 = at2.scode
			))
,[Status] = 

	(CASE
		WHEN
			at.subgroup17 = 'Conversions'
			THEN 'Conversion'

		WHEN 
			(u.sstatus IN ('Vacant Unrented Not Ready', 'Vacant Rented Not Ready') AND crmp.certificationdate IS NULL)
			THEN 'Construction - Initial Rehab'
					
		WHEN 
			(u.sstatus IN ('Vacant Unrented Not Ready', 'Vacant Rented Not Ready') AND crmp.certificationdate IS NOT NULL)
			THEN 'Construction - Turn'

		WHEN
			(u.sstatus = 'Occupied No Notice' AND crmp.certificationdate IS NULL)
			THEN 'Occupied - Initial Rehab Next'
			
		WHEN
			(u.sstatus = 'Occupied No Notice' AND crmp.certificationdate IS NOT NULL)
			THEN 'Occupied - Turn Next'
			
		WHEN
			(u.sstatus IN ('Notice Unrented', 'Notice Rented') AND crmp.certificationdate IS NULL)
			THEN 'Notice - Initial Rehab Next'

		WHEN
			(u.sstatus IN ('Notice Unrented', 'Notice Rented') AND crmp.certificationdate IS NOT NULL)
			THEN 'Notice - Turn Next'
			
		WHEN
			(u.sstatus IN ('Vacant Unrented Ready', 'Vacant Rented Ready') AND (SELECT TOP 1 istatus FROM yardi_stage.dbo.tenant WHERE istatus IN (0,1,2,3,4) AND hproperty = u.hproperty ORDER BY dtsigndate DESC) <> 2 AND (SELECT TOP 1 dtmovein FROM yardi_stage.dbo.tenant WHERE istatus IN (0,1,3,4) AND hproperty = u.hproperty ORDER BY dtsigndate DESC) > crmp.certificationdate)
			THEN 'Rent Ready - Turn'

		WHEN
				(u.sstatus IN ('Vacant Unrented Ready', 'Vacant Rented Ready') 
				 AND ((SELECT crmp.certificationdate WHERE u.scode = crmp.propid) IS NULL 
				 	OR (SELECT TOP 1 dtmovein FROM yardi_stage.dbo.tenant WHERE hproperty = u.hproperty AND istatus IN (0,1,2,3,4) ORDER BY dtmovein DESC) IS NULL
					OR (SELECT crmp.certificationdate WHERE u.scode = crmp.propid)	>
					 	 (SELECT TOP 1 dtmovein FROM yardi_stage.dbo.tenant WHERE hproperty = u.hproperty AND istatus IN (0,1,2,3,4) ORDER BY dtmovein DESC)))
		 	 THEN 'Rent Ready - Initial Rehab'

		WHEN
			(SELECT TOP 1 istatus FROM yardi_stage.dbo.tenant WHERE istatus IN (0,1,2,3,4) AND hproperty = u.hproperty ORDER BY dtsigndate DESC) = 2
			THEN 'Future Tenant'
		ELSE NULL
END)
			
, [Conversion] = (CASE WHEN at.subgroup17 = 'Conversions' THEN 1 ELSE 0 END), [Construction - Initial Rehab] = (CASE WHEN (u.sstatus IN ('Vacant Unrented Not Ready', 'Vacant Rented Not Ready') AND crmp.certificationdate IS NULL) THEN 1 ELSE 0 END), [Construction - Turn] = (CASE WHEN (u.sstatus IN ('Vacant Unrented Not Ready', 'Vacant Rented Not Ready') AND crmp.certificationdate IS NOT NULL) THEN 1 ELSE 0 END), [Occupied - Initial Rehab Next] = (CASE WHEN (u.sstatus = 'Occupied No Notice' AND crmp.certificationdate IS NULL) THEN 1 ELSE 0 END), [Occupied - Turn Next] = (CASE WHEN (u.sstatus = 'Occupied No Notice' AND crmp.certificationdate IS NOT NULL) THEN 1 ELSE 0 END), [Notice - Initial Rehab Next] = (CASE WHEN (u.sstatus IN ('Notice Unrented', 'Notice Rented') AND crmp.certificationdate IS NULL) THEN 1 ELSE 0 END), [Notice - Turn Next] = (CASE WHEN (u.sstatus IN ('Notice Unrented', 'Notice Rented') AND crmp.certificationdate IS NOT NULL) THEN 1 ELSE 0 END
		), [Rent Ready - Turn] = (
		CASE WHEN (
					u.sstatus IN ('Vacant Unrented Ready', 'Vacant Rented Ready') AND (
						SELECT TOP 1 istatus
						FROM Yardi_stage.dbo.tenant
						WHERE istatus IN (0, 1, 2, 3, 4) AND hproperty = u.hproperty
						ORDER BY dtsigndate DESC
						) != 2 AND (
						SELECT TOP 1 dtmovein
						FROM Yardi_stage.dbo.tenant
						WHERE istatus IN (0, 1, 3, 4) AND hproperty = u.hproperty
						ORDER BY dtsigndate DESC
						) > crmp.certificationdate
					) THEN 1 ELSE 0 END
		),[Rent Ready - Initial] =	
	(CASE									
		WHEN
				(u.sstatus IN ('Vacant Unrented Ready', 'Vacant Rented Ready') 
				 AND ((SELECT crmp.certificationdate WHERE u.scode = crmp.propid) IS NULL 
				 	OR (SELECT TOP 1 dtmovein FROM tenant WHERE hproperty = u.hproperty AND istatus IN (0,1,2,3,4) ORDER BY dtmovein DESC) IS NULL
					OR (SELECT crmp.certificationdate WHERE u.scode = crmp.propid)	>
					 	 (SELECT TOP 1 dtmovein FROM tenant WHERE hproperty = u.hproperty AND istatus IN (0,1,2,3,4) ORDER BY dtmovein DESC)))
		 	 THEN 1
		ELSE 0
	END)
, [Future Lease] = (
		CASE WHEN (
					SELECT TOP 1 istatus
					FROM Yardi_stage.dbo.tenant
					WHERE istatus IN (0, 1, 2, 3, 4) AND hproperty = u.hproperty
					ORDER BY dtsigndate DESC
					) = 2 THEN 1 ELSE 0 END
		), [Days in Status] = (
		CASE WHEN at.subgroup17 = 'Conversions' THEN DATEDIFF(DAY, crmp.dateacquired, GETDATE()) WHEN (u.sstatus IN ('Vacant Unrented Not Ready', 'Vacant Rented Not Ready') AND crmp.certificationdate IS NULL) THEN DATEDIFF(DAY, (
							SELECT TOP 1 start
							FROM crm.dbo.construction
							WHERE type = 'Initial Rehab' AND propid = u.scode
							ORDER BY start DESC
							), GETDATE()) WHEN (u.sstatus IN ('Vacant Unrented Not Ready', 'Vacant Rented Not Ready') AND crmp.certificationdate IS NOT NULL) THEN DATEDIFF(DAY, (
							SELECT TOP 1 start
							FROM crm.dbo.construction
							WHERE start + 10 >= (
									SELECT TOP 1 dtmoveout
									FROM Yardi_stage.dbo.tenant
									WHERE hproperty = u.hproperty
									ORDER BY dtmoveout DESC
									) AND type IN ('Initial Rehab', 'Tenant Turn B') AND propid = u.scode
							ORDER BY start ASC
							), GETDATE()) WHEN (
					u.sstatus IN ('Vacant Unrented Ready', 'Vacant Rented Ready') 
				 AND ((SELECT crmp.certificationdate WHERE u.scode = crmp.propid) IS NULL 
				 	OR (SELECT TOP 1 dtmovein FROM tenant WHERE hproperty = u.hproperty AND istatus IN (0,1,2,3,4) ORDER BY dtmovein DESC) IS NULL
					OR (SELECT crmp.certificationdate WHERE u.scode = crmp.propid)	>
					 	 (SELECT TOP 1 dtmovein FROM tenant WHERE hproperty = u.hproperty AND istatus IN (0,1,2,3,4) ORDER BY dtmovein DESC)))
						THEN DATEDIFF(DAY, (
							SELECT TOP 1 start
							FROM crm.dbo.constructionhistory
							WHERE NAME = CONCAT (u.scode, '- Rent Ready')
							ORDER BY start DESC
							), GETDATE()) WHEN (
					u.sstatus IN ('Vacant Unrented Ready', 'Vacant Rented Ready') AND (
						SELECT TOP 1 istatus
						FROM Yardi_stage.dbo.tenant
						WHERE istatus IN (0, 1, 2, 3, 4) AND hproperty = u.hproperty
						ORDER BY dtsigndate DESC
						) != 2 AND (
						SELECT TOP 1 dtmovein
						FROM Yardi_stage.dbo.tenant
						WHERE istatus IN (0, 1, 3, 4) AND hproperty = u.hproperty
						ORDER BY dtsigndate DESC
						) > crmp.certificationdate
					) THEN DATEDIFF(DAY, (
							SELECT TOP 1 start
							FROM crm.dbo.constructionhistory
							WHERE NAME = CONCAT (u.scode, '- Rent Ready')
							ORDER BY start DESC
							), GETDATE()) ELSE NULL END
		), [Purchase Date] = crmp.dateacquired, [Last Move Out] = (
		SELECT TOP 1 dtmoveout
		FROM Yardi_stage.dbo.tenant
		WHERE hproperty = u.hproperty
		ORDER BY dtmoveout DESC
		), [Rent Ready Date] = (
		CASE WHEN (u.sstatus IN ('Vacant Unrented Ready', 'Vacant Rented Ready')) THEN (
						SELECT TOP 1 start
						FROM crm.dbo.constructionhistory
						WHERE NAME = CONCAT (u.scode, '- Rent Ready')
						ORDER BY start DESC
						) ELSE NULL END
		)
FROM yardi_stage.dbo.unit u
LEFT JOIN yardi_stage.dbo.attributes at ON at.hprop = u.hproperty
LEFT JOIN crm.dbo.properties crmp ON crmp.propid = u.scode
WHERE at.subgroup17 IN ('Property Management', 'Conversions')

GO


