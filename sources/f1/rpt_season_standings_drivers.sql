select
    event.season,
    standing.race_round,
    standing.championship_position,
    standing.win_count,
    standing.season_total as points_season,
    driver.driver_code,
    driver.full_name,
    event.event_country,
    country.emoji as country_emoji
from intermediate.int_standings__drivers as standing
left join mart.mart_dim_drivers as driver using (driver_id)
left join mart.mart_dim_sessions as _session using (session_id)
left join mart.mart_dim_events as event using (event_id)
left join seeds.countries as country on lower(country.name) = lower(event.event_country);