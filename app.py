import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Importamos las funciones necesarias
from main import cargar_datos_fuente
from src.data_processing import transformar_fechas, calcular_lead_times_lean

# 1. Configuración de la interfaz
st.set_page_config(page_title="Dashboard Order-to-Cash Lean", layout="wide", page_icon="📊")

# 2. Título Principal
st.title("📊 Cuadro de Mandos Operativo: Order-to-Cash Lean")
st.markdown("### Optimización del Flujo de Caja y Reducción del Tiempo de Ciclo de Cobro")
st.write("---")

# 3. Carga con Caché
@st.cache_data
def obtener_datos_procesados():
    df_crudo = cargar_datos_fuente()
    df_fechas = transformar_fechas(df_crudo)
    return calcular_lead_times_lean(df_fechas)

df = obtener_datos_procesados()

# 4. Estructura de Pestañas
tab1, tab2, tab3 = st.tabs(["📈 KPI Vista General", "🗺️ Value Stream Mapping", "🎯 Automatización y Alertas"])

# PESTAÑA 1
with tab1:
    st.header("📌 Indicadores Clave de Rendimiento (KPIs)")
    df_abiertas = df[df['clear_date'].isna()]
    df_historico = df[df['clear_date'].notna()]
    
    col1, col2, col3 = st.columns(3)
    col1.metric("Capital Comprometido", f"${df_abiertas['total_open_amount'].sum():,.2f}")
    col2.metric("Lead Time Medio", f"{df_historico['Dias_Pago'].mean():.1f} Días")
    col3.metric("Facturas con Retraso", f"{(len(df_historico[df_historico['Dias_Retraso'] > 0]) / len(df_historico)) * 100:.1f}%")
    
    st.caption("⚠️ Nota: El promedio incluye clientes con pronto pago (valores negativos).")
    st.write("---")
    st.info(f"**Histórico:** {len(df_historico):,} transacciones | **Abiertas:** {len(df_abiertas):,} pendientes.")

# PESTAÑA 2: VALUE STREAM MAPPING
with tab2:
    st.header("🗺️ Value Stream Mapping")
    df_h = df[df['clear_date'].notna()].copy()
    df_h['Plazo_Concedido'] = (df_h['due_in_date'] - df_h['posting_date']).dt.days
    
    # Gráfico corregido
    fig, ax = plt.subplots(figsize=(10, 4))
    sns.set_theme(style="whitegrid")
    
    # Barra apilada
    b1 = ax.barh(["Flujo O2C"], [df_h['Dias_Burocracia'].mean()], label="Registro Interno", color="#1f77b4")
    b2 = ax.barh(["Flujo O2C"], [df_h['Plazo_Concedido'].mean()], left=[df_h['Dias_Burocracia'].mean()], label="Plazo Crédito", color="#ff7f0e")
    b3 = ax.barh(["Flujo O2C"], [df_h[df_h['Dias_Retraso'] > 0]['Dias_Retraso'].mean()], left=[df_h['Dias_Burocracia'].mean() + df_h['Plazo_Concedido'].mean()], label="Retraso Cliente", color="#d62728")
    
    ax.set_xlabel("Días Transcurridos")
    # Leyenda movida para no pisar el eje
    ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.25), ncol=3)
    plt.tight_layout()
    st.pyplot(fig)

    st.subheader("🕵️ Distribución de Retrasos")
    fig_box, ax_box = plt.subplots(figsize=(10, 3))
    sns.boxplot(x=df_h['Dias_Retraso'], ax=ax_box, color="#9467bd")
    ax_box.set_xlabel("Días de Retraso")
    st.pyplot(fig_box)

# PESTAÑA 3
with tab3:
    st.header("🎯 Automatización y Pareto")
    df_retrasos = df[(df['clear_date'].notna()) & (df['Dias_Retraso'] > 0)].copy()
    pareto = df_retrasos.groupby('name_customer')['Dias_Retraso'].sum().sort_values(ascending=False).reset_index()
    pareto['%_Acumulado'] = (pareto['Dias_Retraso'].cumsum() / pareto['Dias_Retraso'].sum()) * 100
    st.dataframe(pareto[pareto['%_Acumulado'] <= 85], use_container_width=True, hide_index=True)

    # Sidebar Search
    st.sidebar.write("### 🔍 Buscador de Clientes")
    termino = st.sidebar.text_input("Nombre del cliente:")
    clientes = sorted(df['name_customer'].dropna().unique())
    filtrados = [c for c in clientes if termino.lower() in c.lower()] if termino else clientes
    seleccion = st.sidebar.selectbox("Selecciona cliente:", filtrados)
    
    # Ficha Cliente
    c1, c2 = st.columns(2)
    cliente_data = df[df['name_customer'] == seleccion]
    c1.info(f"**Histórico:** {len(cliente_data[cliente_data['clear_date'].notna()])} pagadas.")
    c2.warning(f"**Pendiente:** ${cliente_data[cliente_data['clear_date'].isna()]['total_open_amount'].sum():,.2f}")