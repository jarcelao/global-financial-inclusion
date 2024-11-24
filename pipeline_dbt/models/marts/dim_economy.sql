with distinct_economies as (

    select distinct on (economycode)
        economycode,
        economy,
        regionwb,
        pop_adult
    from {{ ref('int_surveys_pivoted_to_responses') }}

)

select * from distinct_economies
