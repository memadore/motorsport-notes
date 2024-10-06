---
title: Seasons
---

```sql seasons
select *,
    '/formula_1/seasons/' || season::integer as season_url,
from f1.rpt_seasons_stats
order by season desc
```

Summary of all the Formula 1 seasons. 

<DataTable data={seasons} search=true link=season_url rows=15>
	<Column id=season_url contentType=link linkLabel=season fmt=id title="Season" align=left />
	<Column id=season_start_date title="Start"/>
	<Column id=season_end_date title="End" />
	<Column id=race_count title="Races" align=left/>
	<Column id=driver_world_champion title="Driver" colGroup="World Champions"/>
	<Column id=constructor_world_champion title="Constructor" colGroup="World Champions"/>
</DataTable>