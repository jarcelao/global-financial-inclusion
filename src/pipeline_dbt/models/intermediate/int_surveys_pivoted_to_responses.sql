with findex_survey as (

    select * from {{ ref('stg_raw__global_findex') }}

)

unpivot findex_survey
on columns(* exclude (
    economy,
    economycode,
    regionwb,
    pop_adult,
    wpid_random,
    wgt,
    female,
    age,
    educ,
    inc_q,
    emp_in,
    urbanicity_f2f,
    year
))
into
name question
value response
