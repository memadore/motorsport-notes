select *
from mart.mart_fct_race__driver_classification as result
left join mart.mart_dim_sessions as _session using (session_id)
left join mart.mart_dim_events as event using (event_id)
left join mart.mart_dim_circuits as circuit using (circuit_id)
left join mart.mart_dim_drivers as driver using (driver_id)