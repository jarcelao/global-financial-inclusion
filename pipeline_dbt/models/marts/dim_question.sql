with distinct_questions as (

    select distinct question
    from {{ ref('int_surveys_pivoted_to_responses') }}

)

select
    question,
    row_number() over (order by question) as question_id
from distinct_questions
