---
title: Drivers
---

Lifetime statistics for all the drivers that participated in the Formula 1 world championship.

```sql driver_points
  select driver_code,
    total_points
  from f1.rpt_driver_stats_career
  where total_points > 0
  order by total_points desc
  limit '${inputs.driver_count}'
```

<ButtonGroup name=driver_count>
    <ButtonGroupItem valueLabel="Top 10" value="10" default />
    <ButtonGroupItem valueLabel="Top 100" value="100" />
</ButtonGroup>

<BarChart
    title="Total Points Earned by Drivers"
    data={driver_points}
    x=driver_code
    y=total_points
    labels=true
    swapXY=true
/>
