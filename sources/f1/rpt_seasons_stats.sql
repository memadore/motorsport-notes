with
    world_champions as (
        select
            season as season_id,
            driver.full_name as driver_world_champion,
            constructor.constructor_name as constructor_world_champion
        from intermediate.int_season__world_champions as season
        left join mart.mart_dim_drivers as driver using (driver_id)
        left join mart.mart_dim_constructors as constructor using (constructor_id)
    ),
    calendar as (
        select
            year as season_id,
            min(date) as season_start_date,
            max(date) as season_end_date,
            count(*) as race_count
        from mart.mart_dim_races
        group by year
    )
select
    season.year as season,
    calendar.season_start_date,
    calendar.season_end_date,
    calendar.race_count,
    if(
        season.year = date_part('year', current_date()),
        null,
        world_champion.driver_world_champion
    ) as driver_world_champion,
    if(
        season.year = date_part('year', current_date()),
        null,
        world_champion.constructor_world_champion
    ) as constructor_world_champion,
from mart.mart_dim_seasons as season
left join world_champions as world_champion on season.year = world_champion.season_id
left join calendar on season.year = calendar.season_id
