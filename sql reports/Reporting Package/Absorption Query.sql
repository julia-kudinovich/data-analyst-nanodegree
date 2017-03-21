USE Yardi_Stage;

SELECT

[Prop ID] = t.sunitcode,
[Prop Status] = u.sstatus,
[Division] = rtrim(at.subgroup10),
[Region] = rtrim(at.subgroup18),
[District] = rtrim(at.subgroup9),
[Market] = rtrim(at.subgroup12),
[Market Area] = rtrim(at.subgroup13),
[Entity] = rtrim((SELECT at2.spropname FROM attributes at2 WHERE at.subgroup14 = at2.scode)),
[Tenant Code] = t.scode,
[Tenant Status] = (SELECT status FROM tenstatus WHERE t.istatus = istatus),
[Tenant Sign Date] = t.dtsigndate,
[Tenant Move In] = t.dtmovein,

[Moved In] = (CASE
					WHEN t.dtmovein <= getdate()
						THEN 1
					ELSE 0
				END),

[Upcoming Move In] = (CASE
								WHEN t.dtmovein > getdate()
									THEN 1
								WHEN t.dtsigndate IS NULL
									THEN NULL
								ELSE 0
							END),
								
[Signed 1st-25th] = (CASE
												WHEN (DAY((SELECT TOP 1 dtoccurred FROM tenant_history WHERE sevent = 'Lease Signed' AND htent = t.hmyperson ORDER BY dtoccurred ASC)) < 26 AND (SELECT TOP 1 dtoccurred FROM tenant_history WHERE sevent = 'Lease Signed' AND htent = t.hmyperson ORDER BY dtoccurred ASC) - 20 <= t.dtmovein)
													THEN 1
												ELSE 0
											END),

[Signed 26th-EOM] = (CASE
												WHEN (DAY((SELECT TOP 1 dtoccurred FROM tenant_history WHERE sevent = 'Lease Signed' AND htent = t.hmyperson ORDER BY dtoccurred ASC)) >= 26 AND (SELECT TOP 1 dtoccurred FROM tenant_history WHERE sevent = 'Lease Signed' AND htent = t.hmyperson ORDER BY dtoccurred ASC) - 20 <= t.dtmovein)
													THEN 1
												ELSE 0
											END),

												
[Tenant Move Out Date] = t.dtmoveout,

[Moved Out] = (CASE
						WHEN (t.dtmoveout <= getdate() AND year(t.dtmoveout) != 2099)
							THEN 1
						ELSE 0
					END),
					
[Upcoming Move Out] = (CASE
								WHEN (t.dtmoveout > getdate() AND year(t.dtmoveout) != 2099)
									THEN 1
								ELSE 0
							END)


FROM tenant t

LEFT JOIN unit u ON u.hproperty = t.hproperty
LEFT JOIN attributes at ON at.hprop = t.hproperty

WHERE t.istatus IN (0,1,2,3,4) 