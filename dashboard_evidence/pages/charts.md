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

## 💳 Borrowing and Saving

## 👥 Demographic Insights
