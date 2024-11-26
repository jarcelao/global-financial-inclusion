import plotly.express as px
import streamlit as st

from utils.duckdb_connection import DuckDBConnection


con = DuckDBConnection().get_connection()

account_ownership: float = con.sql(
    """
    with account_fin as (
        select
            response
        from fct_response r
        inner join dim_question q on r.question_id = q.question_id
        where q.question='account_fin'
    )
    select
        sum(response) / count(*) * 100 as account_ownership
    from account_fin
    """
).fetchone()[0]

mobile_money_ownership: float = con.sql(
    """
    with account_mob as (
        select
            response
        from fct_response r
        inner join dim_question q on r.question_id = q.question_id
        where q.question='account_mob'
    )
    select
        sum(response) / count(*) * 100 as mobile_money_ownership
    from account_mob
    """
).fetchone()[0]

saved_or_borrowed: float = con.sql(
    """
    with saved_or_borrowed as (
        select
            response
        from fct_response r
        inner join dim_question q on r.question_id = q.question_id
        where q.question='saved' or q.question='borrowed'
    )
    select
        sum(response) / count(*) * 100 as saved_or_borrowed_pct
    from saved_or_borrowed
    """
).fetchone()[0]

account_ownership_by_country = con.sql(
    """
    select
        e.economycode,
        e.economy,
        e.regionwb as region,
        sum(response) / count(response) * 100 as account_pct
    from fct_response r
    inner join dim_question q on r.question_id = q.question_id
    inner join dim_economy e on r.economy_id = e.economycode
    where q.question='account'
    group by e.economycode, e.economy, e.regionwb
    order by account_pct desc
    """
).fetchdf()

st.set_page_config(page_title="Overview | Global Findex 2021 Dataset", page_icon="📊")

st.write("# 📊 Overview")

st.metric("🏦 Has an account at a financial institution", f"{account_ownership:.2f}%")
st.metric("📱 Has a mobile money account", f"{mobile_money_ownership:.2f}%")
st.metric("💰 Saved or borrowed in the past year", f"{saved_or_borrowed:.2f}%")

st.write("## Account Ownership by Country")

chart_account_ownership_by_country = px.choropleth(
    account_ownership_by_country,
    locations="economycode",
    color="account_pct",
    hover_name="economy",
    hover_data={"region": True},
    color_continuous_scale="RdYlGn",
    labels={"account_pct": "Account Ownership (%)"},
)
chart_account_ownership_by_country.update_layout(geo_bgcolor="rgba(0,0,0,0)")

st.plotly_chart(chart_account_ownership_by_country, use_container_width=True)
