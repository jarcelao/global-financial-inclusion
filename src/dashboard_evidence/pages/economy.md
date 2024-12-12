---
title: 🔍 Economy Dashboard
---

This page focuses on visualizations at a per-economy (i.e. country) level. Use the dropdown below to select the economy you want to learn more about.

<Details title='📝 Notes' open=true>

* This page presents data only from the 2021 iteration of the survey.
* Use the [dataset catalog entry](https://microdata.worldbank.org/index.php/catalog/4607/study-description) as a guide to understanding this page.

</Details>

## ➡️ Select Economy

```sql economies
select distinct
    economycode,
    economy
from global_findex.dim_economy
```

<Dropdown
    data={economies}
    name=select_economy
    value=economycode
    label=economy
    defaultValue="PHL"
/>

```sql fct_response_filtered
select
    *
from global_findex.fct_response
where economy_id = '${inputs.select_economy.value}'
```

## 🔍 Overview

```sql account_ownership_pct
select
    sum(response) / count(response) as pct
from ${fct_response_filtered}
where question='account'
limit 1
```

```sql mobile_money_pct
select
    sum(response) / count(response) as pct
from ${fct_response_filtered}
where question='account_mob'
limit 1
```

```sql digital_pct
select
    sum(response) / count(response) as pct
from ${fct_response_filtered}
where question='anydigpayment'
limit 1
```

```sql borrowed_pct
select
    sum(response) / count(response) as pct
from ${fct_response_filtered}
where question='borrowed'
limit 1
```

```sql economy_ranking
with pcts as (
    select
        economy_id,
        sum(response) / count(response) as pct
    from global_findex.fct_response
    where question='account'
    group by economy_id
),

ranked as (
    select
        *,
        row_number() over (order by pct) as row_num
    from pcts
),

target_row as (
    select
        row_num
    from ranked
    where economy_id = '${inputs.select_economy.value}'
)

select
    economy,
    pct
from ranked r
join global_findex.dim_economy e on r.economy_id = e.economycode
where row_num between (select row_num - 4 from target_row) and (select row_num + 4 from target_row)
```

**Economy KPIs** (% of adults)

<BigValue
    title='Owned an Account'
    data={account_ownership_pct}
    value=pct
    fmt=pct2
/>

<BigValue
    title='Used Mobile Money'
    data={mobile_money_pct}
    value=pct
    fmt=pct2
/>

<BigValue
    title='Used Digital Payments'
    data={digital_pct}
    value=pct
    fmt=pct2
/>

<BigValue
    title='Borrowed Money'
    data={borrowed_pct}
    value=pct
    fmt=pct2
/>

<BarChart
    title="Relative Economy Ranking"
    data={economy_ranking}
    x=economy
    y=pct
    yAxisTitle="Has an account"
    yFmt=pct2
/>

<Alert status=info>
    📝 The above bar chart shows the 4 higher and lower ranking economies than the selected one.
</Alert>

## 💵 Financial Access

```sql account_ownership_access
with respondents as (
    select distinct
        re.respondent_id,
        case when rt.female = 1 then 'Female' else 'Male' end as gender,
        re.response
    from ${fct_response_filtered} re
    join global_findex.dim_respondent rt on re.respondent_id = rt.wpid_random
    where re.question = 'account'
)

select
    sum(response) as value,
    gender as name
from respondents
group by gender
```

```sql no_account_reasons
with respondents as (
    select distinct
        respondent_id,
        case
            when question = 'fin11a' then 'Too far'
            when question = 'fin11b' then 'Too expensive'
            when question = 'fin11c' then 'Lack documentation'
            when question = 'fin11d' then 'Lack trust'
            when question = 'fin11e' then 'Religious reasons'
            when question = 'fin11f' then 'Lack money'
            when question = 'fin11g' then 'Family member already has one'
            when question = 'fin11h' then 'No need for financial services'
        end as question,
        response
    from ${fct_response_filtered}
    where question in (
        'fin11a',
        'fin11b',
        'fin11c',
        'fin11d',
        'fin11e',
        'fin11f',
        'fin11g',
        'fin11h'
    ) and response = 1
)

select
    sum(response) as value,
    question as name
from respondents
group by question
```

<ECharts
    config={
        {
            title: {
                text: 'Account Ownership Breakdown',
                left: 'left'
            },
            tooltip: {
                formatter: '{b}: {c} ({d}%)'
            },
            series: [
                {
                    type: 'pie',
                    radius: ['40%', '70%'],
                    data: [...account_ownership_access],
                }
            ]
        }
    }
/>

<ECharts
    config={
        {
            title: {
                text: 'Reasons for No Account',
                left: 'left'
            },
            tooltip: {
                formatter: '{b}: {c} ({d}%)'
            },
            series: [
                {
                    type: 'pie',
                    radius: ['40%', '70%'],
                    data: [...no_account_reasons],
                }
            ]
        }
    }
/>

## 📱 Digital Payments

```sql digpayment_breakdown
with respondents as (
    select distinct
        re.respondent_id,
        re.response,
        case
            when rt.inc_q = 1 then 'Poorest 20%'
            when rt.inc_q = 2 then 'Second 20%'
            when rt.inc_q = 3 then 'Middle 20%'
            when rt.inc_q = 4 then 'Fourth 20%'
            when rt.inc_q = 5 then 'Richest 20%'
        end as inc_q,
        rt.age
    from ${fct_response_filtered} re
    join global_findex.dim_respondent rt on re.respondent_id = rt.wpid_random
    where re.question = 'anydigpayment'
)

select
    sum(response) as sum,
    inc_q,
    age
from respondents
group by inc_q, age
```

```sql first_digpayments
with respondents as (
    select distinct
        respondent_id,
        response,
        case
            when question = 'fin14_2' then 'Paid digitally for an in-store purchase for the first time after COVID-19'
            when question = 'fin31b1' then 'Paid a utility bill from an account or mobile phone for the first time after COVID-19'
        end as question
    from ${fct_response_filtered}
    where
        question in ('fin14_2', 'fin31b1')
        and response in (1, 2)
)

select
    count(response) as value,
    question as name
from respondents
group by question
```

<BarChart
    title='Digital Payments Breakdown'
    data={digpayment_breakdown}
    x=age
    xAxisTitle='Age'
    y=sum
    yAxisTitle='Made a Digital Payment'
    series=inc_q
    type=stacked
    seriesOrder = {[
        'Poorest 20%',
        'Second 20%',
        'Middle 20%',
        'Fourth 20%',
        'Richest 20%'
    ]}
/>

<ECharts
    config={
        {
            title: {
                text: 'First Digital Payments since COVID-19',
                left: 'left'
            },
            tooltip: {
                formatter: '{b}: {c} ({d}%)'
            },
            series: [
                {
                    type: 'pie',
                    radius: ['40%', '70%'],
                    data: [...first_digpayments],
                }
            ]
        }
    }
/>

## 🤝 Borrowing and Saving

```sql borrowing_means
with respondents as (
    select distinct
        respondent_id,
        case
            when question = 'fin22a' then 'Borrowed from a financial institution'
            when question = 'fin22b' then 'Borrowed from family or friends'
            when question = 'fin22c' then 'Borrowed from an informal savings club'
        end as question,
        response
    from ${fct_response_filtered}
    where
        question in ('fin22a', 'fin22b', 'fin22c')
        and response = 1
)

select
    question as name,
    sum(response) as value
from respondents
group by question
```

```sql saving_means
with respondents as (
    select distinct
        respondent_id,
        case
            when question = 'fin17a' then 'Saved using an account at a financial institution'
            when question = 'fin17a1' then 'Saved using a mobile money account'
            when question = 'fin17b' then 'Saved using an informal savings club'
        end as name,
        response
    from ${fct_response_filtered}
    where question in (
        'fin17a',
        'fin17a1',
        'fin17b',
    ) and response = 1
)

select
    name,
    sum(response) as value
from respondents
group by name
```

<ECharts
    config={
        {
            title: {
                text: 'Means of Borrowing',
                left: 'left'
            },
            tooltip: {
                formatter: '{b}: {c} ({d}%)'
            },
            series: [
                {
                    type: 'pie',
                    radius: ['40%', '70%'],
                    data: [...borrowing_means],
                }
            ]
        }
    }
/>

<ECharts
    config={
        {
            title: {
                text: 'Sources of Savings',
                left: 'left'
            },
            tooltip: {
                formatter: '{b}: {c} ({d}%)'
            },
            series: [
                {
                    type: 'pie',
                    radius: ['40%', '70%'],
                    data: [...saving_means],
                }
            ]
        }
    }
/>

## 👥 Demographics

```sql account_ownership_demographics
select
    sum(re.response) / count(re.response) as pct,
    case
        when rt.educ = 1 then 'Completed primary school or less'
        when rt.educ = 2 then 'Completed secondary school'
        when rt.educ = 3 then 'Completed tertiary education or more'
    end as educ_label,
    rt.educ,
    case
        when rt.inc_q = 1 then 'Poorest 20%'
        when rt.inc_q = 2 then 'Second 20%'
        when rt.inc_q = 3 then 'Middle 20%'
        when rt.inc_q = 4 then 'Fourth 20%'
        when rt.inc_q = 5 then 'Richest 20%'
    end as inc_q_label,
    rt.inc_q
from ${fct_response_filtered} re
join global_findex.dim_respondent rt on re.respondent_id = rt.wpid_random
where re.question = 'account' and rt.educ in (1, 2, 3)
group by rt.educ, rt.inc_q
```

```sql account_ownership_income
select
    sum(re.response) / count(re.response) as pct,
    case
        when rt.inc_q = 1 then 'Poorest 20%'
        when rt.inc_q = 2 then 'Second 20%'
        when rt.inc_q = 3 then 'Middle 20%'
        when rt.inc_q = 4 then 'Fourth 20%'
        when rt.inc_q = 5 then 'Richest 20%'
    end as inc_q
from ${fct_response_filtered} re
join global_findex.dim_respondent rt on re.respondent_id = rt.wpid_random
where re.question = 'account'
group by rt.inc_q
```

<Heatmap
    title='Account Ownership by Income and Education'
    data={account_ownership_demographics}
    x=educ_label
    xAxisTitle='Education Level'
    xSort=educ
    y=inc_q_label
    yAxisTitle='Income Quintile'
    ySort=inc_q
    value=pct
/>

<BarChart
    title='Account Ownership by Income'
    data={account_ownership_income}
    x=inc_q
    xAxisTitle='Income Quintile'
    y=pct
    yAxisTitle='Account Ownership'
    yFmt=pct2
    labels=true
/>
