import streamlit as st
import pandas as pd
import plotly.express as px
from pathlib import Path

st.set_page_config(
    page_title="E-commerce Analytics",
    page_icon="📊",
    layout="wide"
)

BASE = Path(__file__).resolve().parent

@st.cache_data
def load_data():
    monthly = pd.read_csv(
        BASE / "data" / "monthly_sales.csv",
        parse_dates=["order_month"]
    )
    categories = pd.read_csv(
        BASE / "data" / "monthly_categories.csv",
        parse_dates=["order_month"]
    )
    return monthly, categories

monthly, categories = load_data()

st.title("E-commerce Performance Dashboard")
st.caption(
    "Olist Brazilian E-commerce Dataset | "
    "Python · PostgreSQL · dbt · Streamlit"
)

st.sidebar.header("Filters")

months = sorted(monthly["order_month"].dropna().unique())

selected_months = st.sidebar.select_slider(
    "Select reporting period",
    options=list(range(len(months))),
    value=(0, len(months) - 1),
    format_func=lambda i: pd.Timestamp(months[i]).strftime("%b %Y")
)

start_month = months[selected_months[0]]
end_month = months[selected_months[1]]

monthly_filtered = monthly[
    monthly["order_month"].between(start_month, end_month)
].copy()

categories_filtered = categories[
    categories["order_month"].between(start_month, end_month)
].copy()

# Overall KPIs (not filtered by product category)
revenue = monthly_filtered["total_revenue"].sum()
orders = monthly_filtered["total_orders"].sum()
delivered = monthly_filtered["delivered_orders"].sum()

aov = revenue / delivered if delivered else 0

delivery_data = monthly_filtered.dropna(
    subset=["avg_delivery_days"]
)
delivery_weight = delivery_data["delivered_orders"]
avg_delivery = (
    (delivery_data["avg_delivery_days"] * delivery_weight).sum()
    / delivery_weight.sum()
    if delivery_weight.sum() else 0
)

st.subheader("Business overview")

k1, k2, k3, k4 = st.columns(4)

k1.metric("Revenue (delivered)", f"R$ {revenue:,.0f}")
k2.metric("Total orders", f"{orders:,}")
k3.metric("Avg. order value", f"R$ {aov:,.2f}")
k4.metric("Avg. delivery days", f"{avg_delivery:.1f}")

st.divider()

st.subheader("Monthly performance")

left, right = st.columns(2)

with left:
    fig_revenue = px.line(
        monthly_filtered,
        x="order_month",
        y="total_revenue",
        markers=True,
        title="Monthly revenue",
        labels={
            "order_month": "Month",
            "total_revenue": "Revenue (R$)"
        }
    )
    st.plotly_chart(fig_revenue, width="stretch")

with right:
    fig_orders = px.bar(
        monthly_filtered,
        x="order_month",
        y=["total_orders", "delivered_orders"],
        barmode="group",
        title="Orders vs delivered orders",
        labels={
            "order_month": "Month",
            "value": "Orders",
            "variable": "Order status"
        }
    )
    st.plotly_chart(fig_orders, width="stretch")

st.divider()

st.subheader("Product category performance")

available_categories = sorted(
    categories_filtered["product_category"]
    .fillna("unknown").unique()
)

selected_categories = st.multiselect(
    "Filter product categories",
    options=available_categories,
    default=[]
)

category_view = categories_filtered.copy()

if selected_categories:
    category_view = category_view[
        category_view["product_category"].isin(selected_categories)
    ]

category_summary = (
    category_view.groupby(
        "product_category", as_index=False
    )
    .agg(
        revenue=("revenue", "sum"),
        items_sold=("items_sold", "sum")
    )
    .sort_values("revenue", ascending=False)
)

col1, col2 = st.columns(2)

with col1:
    top_categories = category_summary.head(10)

    fig_categories = px.bar(
        top_categories.sort_values("revenue"),
        x="revenue",
        y="product_category",
        orientation="h",
        title="Top product categories by revenue",
        labels={
            "revenue": "Merchandise revenue (R$)",
            "product_category": "Category"
        }
    )
    st.plotly_chart(fig_categories, width="stretch")

with col2:
    category_trend = (
        category_view.groupby("order_month", as_index=False)
        ["revenue"].sum()
    )

    fig_category_trend = px.area(
        category_trend,
        x="order_month",
        y="revenue",
        title="Selected categories: revenue trend",
        labels={
            "order_month": "Month",
            "revenue": "Merchandise revenue (R$)"
        }
    )
    st.plotly_chart(fig_category_trend, width="stretch")

st.subheader("Category details")
st.dataframe(
    category_summary,
    width="stretch",
    hide_index=True
)

st.caption(
    "Data: historical Olist transactions. "
    "Overall revenue is based on payments for delivered orders; "
    "category revenue excludes freight. "
    "Delivery-day KPI is an approximate monthly weighted average."
)
