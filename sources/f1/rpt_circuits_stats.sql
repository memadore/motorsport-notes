with
    lifetime_stats as (
        select
            circuit_id,
            count(_session.session_id) as race_count,
            min(_session.session_start_utc::date) as first_race_date,
            max(_session.session_start_utc::date) as last_race_date
        from mart.mart_dim_sessions as _session
        left join mart.mart_dim_events as event using (event_id)
        where
            _session.session_type like 'race'
            and _session.session_start_utc < current_date()
        group by circuit_id
    )
select
    circuit.circuit_id,
    circuit.circuit_name,
    concat(
        circuit_name, ', ', circuit_location, ', ', circuit_country
    ) as circuit_label,
    circuit.circuit_location,
    circuit.circuit_country,
    circuit.latitude,
    circuit.longitude,
    lifetime_stat.race_count,
    rank() over (order by race_count desc) as race_count_rank,
    case
        when race_count_rank = 1
        then 'st'
        when race_count_rank = 2
        then 'nd'
        when race_count_rank = 3
        then 'rd'
        else 'th'
    end as race_count_rank_suffix,
    lifetime_stat.first_race_date,
    lifetime_stat.last_race_date
from mart.mart_dim_circuits as circuit
left join lifetime_stats as lifetime_stat using (circuit_id)
order by race_count_rank
