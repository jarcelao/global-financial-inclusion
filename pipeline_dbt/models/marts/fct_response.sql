select
    s.wpid_random as respondent_id,
    s.economycode as economy_id,
    q.question_id,
    s.response,
    s.year
from
    {{ ref('int_surveys_pivoted_to_responses') }} as s
inner join
    {{ ref('dim_question') }} as q
    on s.question = q.question
