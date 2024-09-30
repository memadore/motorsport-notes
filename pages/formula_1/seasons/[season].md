# {params.season} Season

## Standings

```sql driver_standings
select *,
    case
        when championship_position = 1 then concat(full_name, ' 🥇')
        when championship_position = 2 then concat(full_name, ' 🥈')
        when championship_position = 3 then concat(full_name, ' 🥉')
        else concat(full_name, ' (', championship_position::int, ')')
    end as driver_label
from f1.rpt_season_standings_drivers
where season = ${params.season}
qualify rank() over (partition by season order by race_round desc) = 1
order by season, race_round, championship_position desc
```

<BarChart
    title="Drivers World Championships"
    subtitle="Points total for the {params.season} season"
    data={driver_standings}
    x=driver_label
    y=points_season
    swapXY=true
    labels=true
/>

####  Points progression through the races

```sql drivers
select distinct full_name
from f1.rpt_season_standings_drivers
where season = ${params.season}
```

<Dropdown
    data={drivers}
    name=driver_selection
    title="Drivers"
    multiple=true
    value=full_name
/>

```sql driver_standings_timeline
select *
from f1.rpt_season_standings_drivers
where season = ${params.season}
    and full_name in ${inputs.driver_selection.value}
order by season, race_round, points_season
```

<LineChart 
    data={driver_standings_timeline}
    x=race_round
    xMin=1
    y=points_season 
    series=full_name
/>

## Drivers

```sql driver_wins
select *
from f1.rpt_season_standings_drivers
where season = ${params.season}
    and win_count > 0
qualify rank() over (partition by season order by race_round desc) = 1
order by season, race_round, championship_position desc
```

<BarChart
    title="Races Wins per Driver"
    subtitle="Win count for the {params.season} season"
    data={driver_wins}
    x=full_name
    y=win_count
    swapXY=true
    labels=true
/>

## Constructors