---
title: Circuits
---

All the tracks that have hosted a Formula 1 race.

```sql circuits
select *,
    '/formula_1/circuits/' || circuit_name as circuit_url,
from f1.rpt_circuits_stats
order by race_count desc
```

<PointMap
    data={circuits} 
    title="Circuit locations"
    lat=latitude
    long=longitude
    value=last_race_date
    valueFmt=shortdate
    pointName=circuit_label
    height=400
/>

<br/>

<DataTable data={circuits} search=true link=circuit_url rows=15>
	<Column id=circuit_url contentType=link linkLabel=circuit_name title="Name" align=left />
	<Column id=circuit_country title="Country" />
	<Column id=circuit_location title="City" />
	<Column id=first_race_date title="First Race" />
	<Column id=last_race_date title="Last Race" />
	<Column id=race_count />
</DataTable>