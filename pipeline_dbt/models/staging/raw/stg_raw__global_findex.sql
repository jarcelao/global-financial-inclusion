with source as (

    select * from {{ source('raw', 'micro_world_139countries') }}

),

renamed as (

    select
        * exclude (wpid_random, wgt, female),
        case when female = 1 then 'female' when female = 2 then 'male' end
            as gender
    from source

)

select * from renamed
