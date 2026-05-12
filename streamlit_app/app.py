import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from sqlalchemy import create_engine, text
import os

# ── Page Config ─────────────────────────────────────────────────────────────
st.set_page_config(
    page_title="Hospital Operations Analytics",
    page_icon="🏥",
    layout="wide",
    initial_sidebar_state="expanded"
)

# ── Dark Theme CSS ───────────────────────────────────────────────────────────
st.markdown("""
<style>
    .stApp { background-color: #0e1117; color: #fafafa; }
    .main-title {
        font-size: 2.5rem;
        font-weight: 800;
        color: #4fc3f7;
        text-align: center;
        padding: 1rem 0 0.2rem 0;
    }
    .sub-title {
        font-size: 1rem;
        color: #90a4ae;
        text-align: center;
        margin-bottom: 2rem;
    }
    .metric-card {
        background: #1e2329;
        border: 1px solid #2d3748;
        border-radius: 10px;
        padding: 1rem;
        text-align: center;
    }
    .metric-value { font-size: 2rem; font-weight: 700; color: #4fc3f7; }
    .metric-label { font-size: 0.85rem; color: #90a4ae; margin-top: 0.3rem; }
    div[data-testid="stSidebar"] { background-color: #161b22; }
    .stSelectbox label, .stMultiSelect label, .stDateInput label { color: #90a4ae; }
</style>
""", unsafe_allow_html=True)

# ── Header ───────────────────────────────────────────────────────────────────
st.markdown('<div class="main-title">🏥 Hospital Operations Analytics Platform</div>', unsafe_allow_html=True)
st.markdown('<div class="sub-title">EAS 550 · Group 4 · Wasiq · Vishal · Pankhudi · Srivardhan</div>', unsafe_allow_html=True)
st.divider()

# ── Database Connection ──────────────────────────────────────────────────────
@st.cache_resource
def get_engine():
    host     = os.environ.get("DB_HOST")
    user     = os.environ.get("DB_USER")
    password = os.environ.get("DB_PASSWORD")
    dbname   = os.environ.get("DB_NAME", "neondb")
    url = f"postgresql+psycopg2://{user}:{password}@{host}/{dbname}?sslmode=require"
    return create_engine(url, pool_size=5, max_overflow=2, pool_pre_ping=True)

# ── Data Loaders ─────────────────────────────────────────────────────────────
@st.cache_data(ttl=300)
def load_fact():
    engine = get_engine()
    with engine.connect() as conn:
        return pd.read_sql(text("""
            SELECT f.appointment_id, f.patient_id, f.doctor_id,
                   f.appointment_date, f.status, f.treatment_type,
                   f.treatment_cost, f.billed_amount,
                   f.payment_method, f.payment_status,
                   f.is_completed, f.is_paid,
                   d.full_name AS doctor_name,
                   d.specialization, d.experience_band,
                   p.full_name AS patient_name,
                   p.gender, p.age_group,
                   dt.month, dt.month_name, dt.quarter, dt.year
            FROM   public_marts.fact_appointments f
            JOIN   public_marts.dim_doctor  d  ON f.doctor_id  = d.doctor_id
            JOIN   public_marts.dim_patient p  ON f.patient_id = p.patient_id
            JOIN   public_marts.dim_date    dt ON f.appointment_date = dt.full_date
        """), conn)

# ── Load Data ────────────────────────────────────────────────────────────────
try:
    df = load_fact()
    df["appointment_date"] = pd.to_datetime(df["appointment_date"])
except Exception as e:
    st.error(f"❌ Database connection failed: {e}")
    st.stop()

# ── Sidebar Filters ──────────────────────────────────────────────────────────
with st.sidebar:
    st.markdown("## 🎛️ Filters")
    st.markdown("---")

    # Date range
    min_date = df["appointment_date"].min().date()
    max_date = df["appointment_date"].max().date()
    date_range = st.date_input("📅 Date Range", value=(min_date, max_date),
                                min_value=min_date, max_value=max_date)

    # Specialization
    specs = ["All"] + sorted(df["specialization"].unique().tolist())
    selected_spec = st.selectbox("🩺 Specialization", specs)

    # Status
    statuses = ["All"] + sorted(df["status"].unique().tolist())
    selected_status = st.selectbox("📋 Appointment Status", statuses)

    # Payment status
    pay_statuses = ["All"] + sorted(df["payment_status"].dropna().unique().tolist())
    selected_pay = st.selectbox("💳 Payment Status", pay_statuses)

    st.markdown("---")
    st.markdown("### 📊 Dashboard Info")
    st.markdown(f"**Total Records:** {len(df)}")
    st.markdown(f"**Date Range:** {min_date} → {max_date}")
    st.markdown(f"**Last Refreshed:** {pd.Timestamp.now().strftime('%H:%M:%S')}")
    if st.button("🔄 Refresh Data"):
        st.cache_data.clear()
        st.rerun()

# ── Apply Filters ─────────────────────────────────────────────────────────────
filtered = df.copy()
if len(date_range) == 2:
    filtered = filtered[
        (filtered["appointment_date"].dt.date >= date_range[0]) &
        (filtered["appointment_date"].dt.date <= date_range[1])
    ]
if selected_spec != "All":
    filtered = filtered[filtered["specialization"] == selected_spec]
if selected_status != "All":
    filtered = filtered[filtered["status"] == selected_status]
if selected_pay != "All":
    filtered = filtered[filtered["payment_status"] == selected_pay]

# ── KPI Metrics ──────────────────────────────────────────────────────────────
col1, col2, col3, col4, col5 = st.columns(5)
total_appts    = len(filtered)
total_revenue  = filtered["billed_amount"].sum()
completed      = filtered["is_completed"].sum()
completion_rate = round((completed / total_appts * 100) if total_appts > 0 else 0, 1)
paid_rate      = round((filtered["is_paid"].sum() / total_appts * 100) if total_appts > 0 else 0, 1)

for col, val, label in zip(
    [col1, col2, col3, col4, col5],
    [total_appts, f"${total_revenue:,.0f}", f"{completed}", f"{completion_rate}%", f"{paid_rate}%"],
    ["Total Appointments", "Total Revenue", "Completed", "Completion Rate", "Paid Rate"]
):
    col.markdown(f"""
    <div class="metric-card">
        <div class="metric-value">{val}</div>
        <div class="metric-label">{label}</div>
    </div>""", unsafe_allow_html=True)

st.markdown("<br>", unsafe_allow_html=True)

# ── Row 1: Revenue by Doctor + Appointments Over Time ────────────────────────
col_left, col_right = st.columns(2)

with col_left:
    st.markdown("### 💰 Revenue by Doctor")
    rev_by_doc = (filtered.groupby("doctor_name")["billed_amount"]
                  .sum().reset_index()
                  .sort_values("billed_amount", ascending=True))
    fig1 = px.bar(rev_by_doc, x="billed_amount", y="doctor_name",
                  orientation="h",
                  color="billed_amount",
                  color_continuous_scale="Blues",
                  labels={"billed_amount": "Revenue ($)", "doctor_name": "Doctor"})
    fig1.update_layout(
        paper_bgcolor="#1e2329", plot_bgcolor="#1e2329",
        font_color="#fafafa", showlegend=False,
        coloraxis_showscale=False,
        margin=dict(l=10, r=10, t=10, b=10)
    )
    st.plotly_chart(fig1, use_container_width=True)

with col_right:
    st.markdown("### 📈 Appointments Over Time")
    appts_time = (filtered.groupby(filtered["appointment_date"].dt.to_period("M"))
                  .size().reset_index(name="count"))
    appts_time["appointment_date"] = appts_time["appointment_date"].astype(str)
    fig2 = px.line(appts_time, x="appointment_date", y="count",
                   markers=True,
                   labels={"appointment_date": "Month", "count": "Appointments"},
                   color_discrete_sequence=["#4fc3f7"])
    fig2.update_layout(
        paper_bgcolor="#1e2329", plot_bgcolor="#1e2329",
        font_color="#fafafa",
        margin=dict(l=10, r=10, t=10, b=10),
        xaxis=dict(gridcolor="#2d3748"),
        yaxis=dict(gridcolor="#2d3748")
    )
    st.plotly_chart(fig2, use_container_width=True)

# ── Row 2: Payment Status Pie + Appointments by Specialization ───────────────
col_left2, col_right2 = st.columns(2)

with col_left2:
    st.markdown("### 💳 Payment Status Breakdown")
    pay_counts = filtered["payment_status"].value_counts().reset_index()
    pay_counts.columns = ["status", "count"]
    fig3 = px.pie(pay_counts, values="count", names="status",
                  color_discrete_sequence=["#4fc3f7", "#81c784", "#e57373", "#ffb74d"],
                  hole=0.4)
    fig3.update_layout(
        paper_bgcolor="#1e2329", plot_bgcolor="#1e2329",
        font_color="#fafafa",
        margin=dict(l=10, r=10, t=10, b=10),
        legend=dict(bgcolor="#1e2329")
    )
    st.plotly_chart(fig3, use_container_width=True)

with col_right2:
    st.markdown("### 🩺 Appointments by Specialization & Status")
    spec_status = (filtered.groupby(["specialization", "status"])
                   .size().reset_index(name="count"))
    fig4 = px.bar(spec_status, x="specialization", y="count", color="status",
                  barmode="group",
                  color_discrete_sequence=px.colors.qualitative.Set2,
                  labels={"specialization": "Specialization", "count": "Appointments"})
    fig4.update_layout(
        paper_bgcolor="#1e2329", plot_bgcolor="#1e2329",
        font_color="#fafafa",
        margin=dict(l=10, r=10, t=10, b=10),
        xaxis=dict(gridcolor="#2d3748"),
        yaxis=dict(gridcolor="#2d3748"),
        legend=dict(bgcolor="#1e2329")
    )
    st.plotly_chart(fig4, use_container_width=True)

# ── Row 3: Revenue by Specialization + Age Group Analysis ────────────────────
col_left3, col_right3 = st.columns(2)

with col_left3:
    st.markdown("### 🏥 Revenue by Specialization")
    rev_spec = (filtered.groupby("specialization")["billed_amount"]
                .sum().reset_index()
                .sort_values("billed_amount", ascending=False))
    fig5 = px.bar(rev_spec, x="specialization", y="billed_amount",
                  color="specialization",
                  color_discrete_sequence=["#4fc3f7", "#81c784", "#ffb74d"],
                  labels={"billed_amount": "Revenue ($)", "specialization": "Specialization"})
    fig5.update_layout(
        paper_bgcolor="#1e2329", plot_bgcolor="#1e2329",
        font_color="#fafafa", showlegend=False,
        margin=dict(l=10, r=10, t=10, b=10),
        xaxis=dict(gridcolor="#2d3748"),
        yaxis=dict(gridcolor="#2d3748")
    )
    st.plotly_chart(fig5, use_container_width=True)

with col_right3:
    st.markdown("### 👥 Patient Age Group Distribution")
    age_counts = filtered["age_group"].value_counts().reset_index()
    age_counts.columns = ["age_group", "count"]
    fig6 = px.pie(age_counts, values="count", names="age_group",
                  color_discrete_sequence=["#4fc3f7", "#81c784", "#e57373", "#ffb74d"],
                  hole=0.4)
    fig6.update_layout(
        paper_bgcolor="#1e2329", plot_bgcolor="#1e2329",
        font_color="#fafafa",
        margin=dict(l=10, r=10, t=10, b=10),
        legend=dict(bgcolor="#1e2329")
    )
    st.plotly_chart(fig6, use_container_width=True)

# ── Raw Data Table ────────────────────────────────────────────────────────────
st.markdown("### 📋 Raw Data Explorer")
cols_show = ["appointment_date", "doctor_name", "specialization",
             "patient_name", "age_group", "status",
             "treatment_type", "treatment_cost", "billed_amount", "payment_status"]
st.dataframe(
    filtered[cols_show].sort_values("appointment_date", ascending=False),
    use_container_width=True,
    height=300
)

st.markdown("---")
st.markdown("<center><small>EAS 550 · Hospital Operations Analytics · Group 4</small></center>",
            unsafe_allow_html=True)
