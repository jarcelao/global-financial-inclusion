---
title: 🌏 Global Dashboard
---

This page focuses on visualizations at a global and regional level.

<Details title='📝 Notes' open=true>

* This page presents data only from the 2021 iteration of the survey.
* Use the [dataset catalog entry](https://microdata.worldbank.org/index.php/catalog/4607/study-description) as a guide to understanding this page.

</Details>

## 🔍 Overview

```sql account_ownership_pct
select
    sum(response) / count(response) as pct
from global_findex.fct_response
where question='account'
limit 1
```

```sql mobile_money_pct
select
    sum(response) / count(response) as pct
from global_findex.fct_response
where question='account_mob'
limit 1
```

```sql digital_pct
select
    sum(response) / count(response) as pct
from global_findex.fct_response
where question='anydigpayment'
limit 1
```

```sql borrowed_pct
select
    sum(response) / count(response) as pct
from global_findex.fct_response
where question='borrowed'
limit 1
```

```sql account_ownership_map
select
    economy_id,
    sum(response) / count(response) as pct
from global_findex.fct_response
where question='account'
group by economy_id
```
**Global KPIs** (% of adults)

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

<AreaMap
    title='Global Account Ownership'
    data={account_ownership_map}
    geoJsonUrl='https://d2ad6b4ur7yvpq.cloudfront.net/naturalearth-3.3.0/ne_110m_admin_0_countries.geojson'
    areaCol=economy_id
    geoId=brk_a3
    value=pct
    valueFmt=pct2
/>

## 💵 Financial Access

```sql account_ownership_access
with respondents as (
    select distinct
        re.respondent_id,
        re.response,
        e.regionwb as region,
        case when rt.female = 1 then 'female' else 'male' end as gender
    from global_findex.fct_response re
    join global_findex.dim_respondent rt on re.respondent_id = rt.wpid_random
    join global_findex.dim_economy e on re.economy_id = e.economycode
    where re.question = 'account' and e.regionwb is not null
)

select
    sum(response) as sum,
    region,
    gender
from respondents
group by region, gender
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
    from global_findex.fct_response
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

<BarChart
    title='Account Ownership Breakdown'
    data={account_ownership_access}
    x=region
    y=sum
    yAxisTitle='Has an Account'
    series=gender
    type=grouped
    swapXY=true
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
    from global_findex.fct_response re
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
        re.respondent_id,
        re.response,
        case
            when re.question = 'fin14_2' then 'Paid digitally for an in-store purchase for the first time after COVID-19'
            when re.question = 'fin31b1' then 'Paid a utility bill from an account or mobile phone for the first time after COVID-19'
        end as question,
        e.regionwb as region
    from global_findex.fct_response re
    join global_findex.dim_economy e on re.economy_id = e.economycode
    where
        re.question in ('fin14_2', 'fin31b1')
        and response in (1, 2)
)

select
    count(response) as sum,
    question,
    region
from respondents
group by question, region
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

<BarChart
    title='First Digital Payment since COVID-19'
    data={first_digpayments}
    x=region
    y=sum
    yAxisTitle='Answered Yes'
    series=question
    type=grouped
    swapXY=true
/>

## 🤝 Borrowing and Saving

```sql borrowing_means
with respondents as (
    select distinct
        re.respondent_id,
        e.regionwb as region,
        case
            when re.question = 'fin22a' then 'Borrowed from a financial institution'
            when re.question = 'fin22b' then 'Borrowed from family or friends'
            when re.question = 'fin22c' then 'Borrowed from an informal savings club'
        end as question,
        response
    from global_findex.fct_response re
    join global_findex.dim_economy e on re.economy_id = e.economycode
    where
        re.question in ('fin22a', 'fin22b', 'fin22c')
        and re.response = 1
        and e.regionwb is not null
)

select
    region,
    question,
    sum(response) as sum
from respondents
group by region, question
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
    from global_findex.fct_response
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

<BarChart
    title='Means of Borrowing'
    data={borrowing_means}
    x=region
    y=sum
    yAxisTitle='Has an Account'
    series=question
    type=grouped
    swapXY=true
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
from global_findex.fct_response re
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
from global_findex.fct_response re
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
