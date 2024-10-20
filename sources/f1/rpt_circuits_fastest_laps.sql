select circuit.circuit_name,
    _session.session_start_utc::date as session_start_utc,
    driver.full_name,
    '/formula_1/drivers/' || full_name as driver_url,
    full_name || ' →' as driver_label,
    result.fastest_lap_time,
    epoch(result.fastest_lap_time) as fastest_lap_time_seconds,
    cast(fastest_lap_time as string)[5:] as time_label
from mart.mart_fct_race__driver_fastest_lap as result
left join mart.mart_dim_sessions as _session using (session_id)
left join mart.mart_dim_events as event using (event_id)
left join mart.mart_dim_circuits as circuit using (circuit_id)
left join mart.mart_dim_drivers as driver using (driver_id)
where fastest_lap_rank = 1
order by circuit.circuit_id, fastest_lap_time