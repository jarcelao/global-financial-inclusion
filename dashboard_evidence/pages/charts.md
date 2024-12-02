---
title: 📊 Charts
---

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

## 🪙 Financial Access

```sql account_ownership_access
select
    sum(re.response) as sum,
    e.regionwb as region,
    case when rt.female = 1 then 'female' else 'male' end as gender
from global_findex.fct_response re
join global_findex.dim_respondent rt on re.respondent_id = rt.wpid_random
join global_findex.dim_economy e on re.economy_id = e.economycode
where re.question = 'account' and e.regionwb is not null
group by e.regionwb, rt.female
```

```sql no_account_reasons
select
    case
        when question = 'fin11a' then 'too far'
        when question = 'fin11b' then 'too expensive'
        when question = 'fin11c' then 'lack documentation'
        when question = 'fin11d' then 'lack trust'
        when question = 'fin11e' then 'religious reasons'
        when question = 'fin11f' then 'lack money'
        when question = 'fin11g' then 'family member already has one'
        when question = 'fin11h' then 'no need for financial services'
    end as name,
    sum(response) as value
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
select
    sum(re.response) as sum,
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
group by rt.inc_q, age
```

```sql first_digpayments
select
    sum(re.response) as sum,
    case
        when re.question = 'fin14_2' then 'Paid digitally for an in-store purchase for the first time after COVID-19'
        when re.question = 'fin31b1' then 'Paid a utility bill from an account or mobile phone for the first time after COVID-19'
    end as question,
    e.regionwb as region
from global_findex.fct_response re
join global_findex.dim_economy e on re.economy_id = e.economycode
where re.question in ('fin14_2', 'fin31b1')
group by re.question, e.regionwb
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

## 💳 Borrowing and Saving

## 👥 Demographic Insights
