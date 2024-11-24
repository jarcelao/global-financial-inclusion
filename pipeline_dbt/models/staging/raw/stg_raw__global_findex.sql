-- We'll materialize this as a table as a workaround to ignore upstream errors from the csv
{{ config(materialized='table') }}

with source as (

    select * from {{ source('raw', 'micro_world_139countries') }}

),

renamed as (

    -- DuckDB incorrectly inferred some variables in the dataset as VARCHARs.
    -- Thus, we cast them to BIGINTs for consistency.

    select
        * exclude (
            fin10_1a,
            fin10_1b,
            fin10_1c,
            fin10_1d,
            fin10_1e,
            fin14_2_china,
            fin14c_2_china,
            fin31b1_china,
            fin45_1_china
        ),
        cast(fin10_1a as bigint) as fin10_1a,
        cast(fin10_1b as bigint) as fin10_1b,
        cast(fin10_1c as bigint) as fin10_1c,
        cast(fin10_1d as bigint) as fin10_1d,
        cast(fin10_1e as bigint) as fin10_1e,
        cast(fin14_2_china as bigint) as fin14_2_china,
        cast(fin14c_2_china as bigint) as fin14c_2_china,
        cast(fin31b1_china as bigint) as fin31b1_china,
        cast(fin45_1_china as bigint) as fin45_1_china
    from source

)

select * from renamed
