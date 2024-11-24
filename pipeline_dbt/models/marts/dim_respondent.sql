with distinct_respondents as (

    select
        wpid_random,
        wgt,
        female,
        age,
        educ,
        inc_q,
        emp_in,
        urbanicity_f2f
    from {{ ref('int_surveys_pivoted_to_responses') }}

)

select * from distinct_respondents
