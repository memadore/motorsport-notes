# {params.circuit}

```sql circuit_stats
select *,
    date_sub('years', first_race_date, current_date()) as years_since_first_race,
    date_sub('days', last_race_date, current_date()) as days_since_last_race,
from f1.rpt_circuits_stats
where circuit_name like '${params.circuit}'
```

## Location

The track is located in <Value data={circuit_stats} column=circuit_location />, <Value data={circuit_stats} column=circuit_country />.

<PointMap
    data={circuit_stats}
    lat=latitude
    long=longitude
    valueFmt=shortdate
    pointName=circuit_label
    height=300
/>

---

## Grand Prix

```sql circuit_races
with race_rank as (
    select if(race_count_rank - 3 < 1, 0, race_count_rank - 3) as offset
    from f1.rpt_circuits_stats
    where circuit_name like '${params.circuit}'
)
select
    concat(
        circuit_name,
        ' (',
        race_count_rank::int,
        ')'
    ) as circuit_name,
    race_count
from f1.rpt_circuits_stats
offset (select * from race_rank)
limit 5
```

<BigValue
  data={circuit_stats}
  title="First Race"
  value=first_race_date
  fmt=longdate
  comparison=years_since_first_race
  comparisonFmt=id
  comparisonTitle="Years Ago"
  comparisonDelta=false
/>

<BigValue
  data={circuit_stats}
  title="Last Race"
  value=last_race_date
  fmt=longdate
  comparison=days_since_last_race
  comparisonFmt=id
  comparisonTitle="Days Ago"
  comparisonDelta=false
/>

<BigValue
  data={circuit_stats}
  title="Grand Prix Hosted"
  value=race_count
  fmt=id
/>

<BarChart
    title="Number of Grand Prix hosted ranking"
    data={circuit_races}
    x=circuit_name
    y=race_count
    swapXY=true
    labels=true
>
<ReferenceArea xMin={params.circuit} xMax={params.circuit}/>
</BarChart>

### Qualifying



### Races

```sql circuit_winners
select circuit_name,
    arg_min(full_name, first_win) as first_driver_winner,
    min(first_win) as first_win_date,
    arg_max(full_name, last_win) as last_driver_winner,
    max(last_win) as last_win_date,
    count(distinct if(win_count > 0, full_name, null)) as different_winners
from f1.rpt_circuits_drivers
where circuit_name like '${params.circuit}'
group by circuit_name
```

<BigValue
  data={circuit_winners}
  title="First Winner"
  value=first_driver_winner
  comparison=first_win_date
  comparisonFmt=longdate
  comparisonTitle=""
  comparisonDelta=false
/>

<BigValue
  data={circuit_winners}
  title="Latest Winner"
  value=last_driver_winner
  comparison=last_win_date
  comparisonFmt=longdate
  comparisonTitle=""
  comparisonDelta=false
/>

<BigValue
  data={circuit_winners}
  title="Different Winners"
  value=different_winners
/>

```sql race_position
select circuit_name,
    grid_position,
    classification,
    count(*) as occurence
from f1.rpt_circuits_races
where circuit_name like '${params.circuit}'
group by 1, 2, 3
order by circuit_name, grid_position, classification
```

```sql race_position_line
select circuit_name,
    0 as min_xy,
    max(grid_position) as max_grid_position,
    max(classification) as max_classification,
    if(max_grid_position <= max_classification, max_grid_position, max_classification) as max_xy
from f1.rpt_circuits_races
where circuit_name like '${params.circuit}'
group by 1
```

<BubbleChart
    data={race_position}
    title="Final Classification by Starting Grid Position"
    subtitle="The race was won from pole {race_position[0].occurence} times"
    x=grid_position
    y=classification
    size=occurence
    chartAreaHeight=250
>
    <ReferenceLine data={race_position_line} x=min_xy y=min_xy x2=max_xy y2=max_xy label="Positions Gained" labelPosition=belowEnd/>
    <ReferenceLine data={race_position_line} x=min_xy y=min_xy x2=max_xy y2=max_xy label="Positions Lost" labelPosition=aboveEnd/>
</BubbleChart>


#### Fastest Laps

```sql circuit_fastest_laps
select *
from f1.rpt_circuits_fastest_laps
where circuit_name like '${params.circuit}'
```

```sql circuit_fastest_lap
select *
from f1.rpt_circuits_fastest_laps
where circuit_name like '${params.circuit}'
order by fastest_lap_time_seconds
limit 1
```

<BigValue
  data={circuit_fastest_lap}
  title="Fastest Lap"
  value=time_label
/>

<BigValue
  data={circuit_fastest_lap}
  title="Driver"
  value=full_name
/>

<BigValue
  data={circuit_fastest_lap}
  title="Date"
  value=session_start_utc
  fmt=longdate
/>

<Grid cols=2>
    <LineChart
        data={circuit_fastest_laps}
        title="Fastest Race Lap time"
        subtitle="Current record is {circuit_fastest_lap[0].time_label} by {circuit_fastest_lap[0].full_name}"
        x=session_start_utc
        y=fastest_lap_time_seconds
        yAxisTitle="Lap time in seconds"
        chartAreaHeight=235
        markers=true
        markerShape=emptyCircle
    />

    <DataTable data={circuit_fastest_laps}>
        <Column id=driver_url title="Driver" contentType=link linkLabel=driver_label align="right" />
        <Column id=session_start_utc title="Date" />
        <Column id=time_label title="Lap Time" />
    </DataTable>
</Grid>


---

## Drivers

```sql drivers
select distinct full_name
from f1.rpt_circuits_drivers
where circuit_name like '${params.circuit}'
```

<Dropdown
    data={drivers}
    name=driver_selection
    title="Drivers"
    multiple=true
    value=full_name
    selectAllByDefault=true
/>

```sql circuit_driver_race_count
select
    full_name,
    race_count
from f1.rpt_circuits_drivers
where circuit_name like '${params.circuit}'
    and full_name in ${inputs.driver_selection.value}
order by circuit_name, race_count desc
limit 10
```

```sql circuit_driver_win_count
select
    full_name,
    win_count
from f1.rpt_circuits_drivers
where circuit_name like '${params.circuit}'
    and full_name in ${inputs.driver_selection.value}
order by circuit_name, win_count desc
limit 10
```

```sql circuit_driver_podium_count
select
    full_name,
    podium_count
from f1.rpt_circuits_drivers
where circuit_name like '${params.circuit}'
    and full_name in ${inputs.driver_selection.value}
order by circuit_name, podium_count desc
limit 10
```

```sql circuit_driver_points
select
    full_name,
    points_total
from f1.rpt_circuits_drivers
where circuit_name like '${params.circuit}'
    and full_name in ${inputs.driver_selection.value}
order by circuit_name, points_total desc
limit 10
```

<Grid cols=2>
<BarChart
    title="Race Count"
    subtitle="Top 10 drivers who participated in a Grand Prix"
    data={circuit_driver_race_count}
    x=full_name
    y=race_count
    swapXY=true
    labels=true
/>
<BarChart
    title="Win Count"
    subtitle="Top 10 drivers who won the most races"
    data={circuit_driver_win_count}
    x=full_name
    y=win_count
    swapXY=true
    labels=true
/>
<BarChart
    title="Podium Count"
    subtitle="Top 10 drivers who had the most podiums"
    data={circuit_driver_podium_count}
    x=full_name
    y=podium_count
    swapXY=true
    labels=true
/>
<BarChart
    title="Points Total"
    subtitle="Top 10 drivers with the most points"
    data={circuit_driver_points}
    x=full_name
    y=points_total
    swapXY=true
    labels=true
/>
</Grid>

```sql circuit_driver
select * exclude (circuit_name),
    '/formula_1/drivers/' || full_name as driver_url,
     full_name || ' →' as driver_label
from f1.rpt_circuits_drivers
where circuit_name like '${params.circuit}'
order by circuit_name, win_count desc
```

<DataTable data={circuit_driver} search=true>
    <Column id=driver_url title="Driver" contentType=link linkLabel=driver_label align="right" />
    <Column id=race_count title="Races" />
    <Column id=lap_count title="Laps" />
    <Column id=win_count title="Count" colGroup="Wins"/>
    <Column id=win_ratio title="Ratio" colGroup="Wins" fmt='pct2'/>
    <Column id=podium_count title="Count" colGroup="Podiums"/>
    <Column id=podium_ratio title="Ratio" colGroup="Podiums" fmt='pct2'/>
    <Column id=top10_count title="Count" colGroup="Top 10"/>
    <Column id=top10_ratio title="Ratio" colGroup="Top 10" fmt='pct2'/>
    <Column id=points_total title="Total" colGroup="Points" />
    <Column id=points_average title="Average" colGroup="Points" />
    <Column id=dnf_count title="Count" colGroup="DNFs"/>
    <Column id=dnf_ratio title="Ratio" colGroup="DNFs" fmt='pct2'/>
</DataTable>

---

## Teams
