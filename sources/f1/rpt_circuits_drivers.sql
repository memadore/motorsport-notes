select circuit.circuit_name,
    driver.full_name,
    count(*) as race_count,
    sum(if(result.classification = 1, 1, 0)) as win_count,
    round(divide(win_count, race_count * 1.0), 4) as win_ratio,
    min(if(result.classification = 1, _session.session_start_utc::date, null)) as first_win,
    max(if(result.classification = 1, _session.session_start_utc::date, null)) as last_win,
    sum(if(result.classification <= 3, 1, 0)) as podium_count,
    round(divide(podium_count, race_count * 1.0), 4) as podium_ratio,
    min(if(result.classification <= 3, _session.session_start_utc::date, null)) as first_podium,
    max(if(result.classification <= 3, _session.session_start_utc::date, null)) as last_podium,
    sum(if(result.classification <= 10, 1, 0)) as top10_count,
    round(divide(top10_count, race_count * 1.0), 4) as top10_ratio,
    min(if(result.classification <= 10, _session.session_start_utc::date, null)) as first_top10,
    max(if(result.classification <= 10, _session.session_start_utc::date, null)) as last_top10,
    sum(if(result.classification is null, 1, 0)) as dnf_count,
    round(divide(dnf_count, race_count * 1.0), 4) as dnf_ratio,
    min(if(result.classification = 1, _session.session_start_utc::date, null)) as first_win,
    max(if(result.classification = 1, _session.session_start_utc::date, null)) as last_win,
    sum(result.points) as points_total,
    round(divide(points_total, race_count * 1.0), 4) as points_average,
    sum(result.laps_completed) as lap_count,
from mart.mart_fct_race__driver_classification as result
left join mart.mart_dim_sessions as _session using (session_id)
left join mart.mart_dim_events as event using (event_id)
left join mart.mart_dim_circuits as circuit using (circuit_id)
left join mart.mart_dim_drivers as driver using (driver_id)
group by 1, 2