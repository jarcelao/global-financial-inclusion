select
    s.wpid_random as respondent_id,
    s.economycode as economy_id,
    s.question,
    s.response,
    s.year
from
    {{ ref('int_surveys_pivoted_to_responses') }} as s
