---
title: 📊 Insights
---

<Details title='📝 Notes' open=true>

* This page presents data only from the 2021 iteration of the survey.
* Percentages are representative of the global adult population unless stated otherwise.
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

## 📱 Digital Payments

## 💳 Borrowing and Saving

## 👥 Demographic Insights
