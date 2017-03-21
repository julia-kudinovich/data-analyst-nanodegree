USE Yardi_Stage;

SELECT
	 
  [Prop ID] = u.scode
, [Unit Status] = u.sstatus
, [Market] = rtrim(at.subgroup12)
, [Tenant Code] = t.scode
, [Tenant Status] = (SELECT STATUS FROM tenstatus WHERE istatus = t.istatus)
, [MTM?] = t.bmtm*-1
, [Old Lease From] = lh.dtleasefrom 
, [Old Lease To] = lh.dtleaseto
, [Month Expiration] = MONTH(lh.dtleaseto)
, [Year Expiration] = YEAR(lh.dtleaseto)
, [Tenant Move Out] = t.dtmoveout
, [Renewal Event Type] = renewal_event_type.sevent
, [Renewal Event Date] = renewal_event_date.dtoccurred
, [Lease Status] = new_lease.sstatus
, [New Lease From] = new_lease.dtleasefrom
, [New Lease To] = new_lease.dtleaseto
, [Length of New Lease] = DATEDIFF(DAY, new_lease.dtleasefrom, new_lease.dtleaseto)
, [New Recurring Charges] = ISNULL(nrr.destimated,0)+ISNULL(nrmtm.destimated,0)+ISNULL(nrho.destimated,0)+ISNULL(nrpf.destimated,0)
, [Old Recurring Charges] = ISNULL(orr.destimated,0)+ISNULL(ormtm.destimated,0)+ISNULL(orho.destimated,0)+ISNULL(orpf.destimated,0)
, [New Recurring Rent] = nrr.destimated
, [New Recurring MTM] = nrmtm.destimated
, [New Recurring Holdover] = nrho.destimated
, [New Recurring Proc Fee] = nrpf.destimated
, [Old Recurring Rent] = orr.destimated
, [Old Recurring MTM] = ormtm.destimated
, [Old Recurring Holdover] = orho.destimated
, [Old Recurring Proc Fee] = orpf.destimated

FROM lease_history lh

INNER JOIN tenant t ON t.hmyperson = lh.htent
INNER JOIN unit u ON t.hproperty = u.hproperty
INNER JOIN attributes at ON at.hprop = t.hproperty

OUTER APPLY
	(SELECT TOP 1 dtoccurred FROM tenant_history WHERE htent = lh.htent AND sevent IN ('Lease Renewal', 'Lease Renewal Canceled') ORDER BY dtoccurred DESC) renewal_event_date

OUTER APPLY
	(SELECT TOP 1 * FROM tenant_history WHERE htent = lh.htent AND sevent IN ('Lease Renewal', 'Lease Renewal Canceled') ORDER BY dtoccurred DESC) renewal_event_type

OUTER APPLY
	(SELECT TOP 1 * FROM lease_history WHERE lh.htent = htent AND istatus IN (2,4,5) AND dtleasefrom > lh.dtleaseto) new_lease

OUTER APPLY
	(SELECT TOP 1 destimated FROM camrule WHERE htenant = lh.htent AND hchargecode = 11 AND (dtto IS NULL OR dtto > (lh.dtleaseto-45)) AND dtfrom < new_lease.dtleaseto ORDER BY dtfrom DESC) nrr

OUTER APPLY
	(SELECT TOP 1 destimated FROM camrule WHERE htenant = lh.htent AND hchargecode = 10 AND (dtto IS NULL OR dtto > (lh.dtleaseto-45)) AND dtfrom < new_lease.dtleaseto ORDER BY dtfrom DESC) nrmtm

OUTER APPLY
	(SELECT TOP 1 destimated FROM camrule WHERE htenant = lh.htent AND hchargecode = 18 AND (dtto IS NULL OR dtto > (lh.dtleaseto-45)) AND dtfrom < new_lease.dtleaseto ORDER BY dtfrom DESC) nrpf

OUTER APPLY
	(SELECT TOP 1 destimated FROM camrule WHERE htenant = lh.htent AND hchargecode = 20 AND (dtto IS NULL OR dtto > (lh.dtleaseto-45)) AND dtfrom < new_lease.dtleaseto ORDER BY dtfrom DESC) nrho

OUTER APPLY
	(SELECT TOP 1 destimated FROM camrule WHERE htenant = lh.htent AND hchargecode = 11 AND dtfrom < (lh.dtleaseto-45) ORDER BY dtto DESC, dtfrom DESC) orr

OUTER APPLY
	(SELECT TOP 1 destimated FROM camrule WHERE htenant = lh.htent AND hchargecode = 10 AND dtfrom < (lh.dtleaseto-45) ORDER BY dtto DESC, dtfrom DESC) ormtm

OUTER APPLY
	(SELECT TOP 1 destimated FROM camrule WHERE htenant = lh.htent AND hchargecode = 18 AND dtfrom < (lh.dtleaseto-45) ORDER BY dtto DESC, dtfrom DESC) orpf

OUTER APPLY
	(SELECT TOP 1 destimated FROM camrule WHERE htenant = lh.htent AND hchargecode = 20 AND dtfrom < (lh.dtleaseto-45) ORDER BY dtto DESC, dtfrom DESC) orho

WHERE lh.dtleaseto BETWEEN '2015-01-01' AND GETDATE()
AND t.scode = 't0030281'	