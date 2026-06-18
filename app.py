import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Importamos la función de carga desde tu main.py
from main import cargar_datos_fuente
# Importamos las transformaciones lógicas desde src
from src.data_processing import transformar_fechas, calcular_lead_times_lean

# 1. Configuración de la interfaz del navegador
st.set_page_config(
    page_title="Dashboard Order-to-Cash Lean",
    layout="wide",
    page_icon="📊"
)

# 2. Título Principal y Encabezado de Enfoque Lean Six Sigma
st.title("📊 Cuadro de Mandos Operativo: Order-to-Cash Lean")
st.markdown("### Optimización del Flujo de Caja y Reducción del Tiempo de Ciclo de Cobro")
st.write("---")

# 3. Carga e Inyección de Datos Optimizada con Caché
@st.cache_data
def obtener_datos_procesados():
    # Reutilizamos tu pipeline exacto paso a paso
    df_crudo = cargar_datos_fuente()
    df_fechas = transformar_fechas(df_crudo)
    df_final = calcular_lead_times_lean(df_fechas)
    return df_final

# Ejecutamos la carga (gracias al caché, solo leerá el CSV la primera vez)
df = obtener_datos_procesados()

# 4. Creación de la Estructura de Pestañas (Tabs)
tab1, tab2, tab3 = st.tabs([
    "📈 KPI Vista General", 
    "🗺️ Value Stream Mapping", 
    "🎯 Automatización y Alertas"
])

# ==================================================
# PESTAÑA 1: KPI VISTA GENERAL (MÉTRICAS FINANCIERAS)
# ==================================================
with tab1:
    st.header("📌 Indicadores Clave de Rendimiento (KPIs)")
    st.markdown("Visión estratégica sobre la liquidez actual y la eficiencia histórica del ciclo de cobros.")
    st.write("---")
    
    # --- PROCESAMIENTO INTERNO DE MÉTRICAS PARA PANTALLA ---
    # Facturas Abiertas (Cuentas por cobrar vivas en la calle: clear_date es nulo)
    df_abiertas = df[df['clear_date'].isna()]
    capital_comprometido = df_abiertas['total_open_amount'].sum()
    
    # Facturas Históricas (Transacciones cobradas del pasado)
    df_historico = df[df['clear_date'].notna()]
    lead_time_medio = df_historico['Dias_Pago'].mean()
    
    # Porcentaje de Facturas con Retraso Comercial (Dias_Retraso > 0)
    facturas_con_retraso = df_historico[df_historico['Dias_Retraso'] > 0]
    porcentaje_retraso = (len(facturas_con_retraso) / len(df_historico)) * 100

    # --- DISEÑO VISUAL EN COLUMNAS (TARJETAS KPI) ---
    col1, col2, col3 = st.columns(3)
    
    with col1:
        st.metric(
            label="Capital Comprometido (En la calle)",
            value=f"${capital_comprometido:,.2f}",
            help="Suma total de la columna total_open_amount de todas las facturas que siguen abiertas."
        )
        
    with col2:
        st.metric(
            label="Lead Time Medio de Cobro",
            value=f"{lead_time_medio:.1f} Días",
            help="Promedio de días que transcurren desde la creación del documento hasta el cobro real."
        )
        
    with col3:
        st.metric(
            label="Facturas con Retraso (%)",
            value=f"{porcentaje_retraso:.1f}%",
            help="Proporción de facturas históricas cobradas fuera de su fecha límite de vencimiento."
        )
        
    # NUEVO: Nota de advertencia analítica para el usuario
    st.caption("⚠️ **Nota analítica:** El promedio global de días está fuertemente compensado por clientes con pronto pago (valores negativos). Para ver el impacto real de los cuellos de botella, consulte la dispersión en la pestaña 'Value Stream Mapping'.")
    st.write("---")
    
    # --- TABLA DE VOLÚMENES PARA SECTOR OPERATIVO ---
    st.subheader("📋 Resumen Operativo de Volúmenes")
    col_v1, col_v2 = st.columns(2)
    with col_v1:
        st.info(f"**Facturas Históricas Analizadas:** {len(df_historico):,} transacciones liquidadas.")
    with col_v2:
        st.warning(f"**Facturas Abiertas en Gestión:** {len(df_abiertas):,} cuentas pendientes de cobro.")

## ==================================================
# PESTAÑA 2: VALUE STREAM MAPPING (ANÁLISIS DE TIEMPOS)
# ==================================================
with tab2:
    st.header("🗺️ Value Stream Mapping (Mapa de Flujo de Valor)")
    st.markdown("Análisis visual de los tiempos de ciclo para identificar cuellos de botella en el proceso Order-to-Cash.")
    st.write("---")
    
    # Filtramos el histórico (facturas cobradas) para medir procesos reales
    df_h = df[df['clear_date'].notna()].copy()
    
    # Calcular las medias de cada fase del flujo
    media_burocracia = df_h['Dias_Burocracia'].mean()
    
    # Plazo concedido promedio (Vencimiento - Publicación)
    df_h['Plazo_Concedido'] = (df_h['due_in_date'] - df_h['posting_date']).dt.days
    media_plazo = df_h['Plazo_Concedido'].mean()
    
    # Retraso medio real (solo de las que se retrasaron > 0 para ver el impacto del cuello de botella)
    media_retraso_real = df_h[df_h['Dias_Retraso'] > 0]['Dias_Retraso'].mean()
    
    # --- INTERFAZ MÉTRICA DE TIEMPOS ---
    st.subheader("⏱️ Desglose del Tiempo de Ciclo Medio")
    v_col1, v_col2, v_col3 = st.columns(3)
    v_col1.metric("1. Registro Interno (Burocracia)", f"{media_burocracia:.1f} días")
    v_col2.metric("2. Espera de Vencimiento (Crédito)", f"{media_plazo:.1f} días")
    v_col3.metric("3. Retraso de Cobro (Cuello de Botella)", f"{media_retraso_real:.1f} días")
    
    st.write("---")
    
    # --- GRÁFICO: VALUE STREAM MAPPING ---
    st.subheader("📊 Línea de Tiempo Acumulada del Proceso")
    
    # Configuración del gráfico Matplotlib/Seaborn
    fig, ax = plt.subplots(figsize=(10, 2.5))
    sns.set_theme(style="whitegrid")
    
    # Crear las barras horizontales apiladas
    ax.barh(["Flujo O2C"], [media_burocracia], label="Registro Interno", color="#1f77b4")
    ax.barh(["Flujo O2C"], [media_plazo], left=[media_burocracia], label="Plazo de Crédito", color="#ff7f0e")
    ax.barh(["Flujo O2C"], [media_retraso_real], left=[media_burocracia + media_plazo], label="Retraso del Cliente", color="#d62728")
    
    # Añadir etiquetas con los valores encima de las barras
    ax.text(media_burocracia/2, 0, f"{media_burocracia:.1f}d", va='center', ha='center', color='white', fontweight='bold')
    ax.text(media_burocracia + (media_plazo/2), 0, f"{media_plazo:.1f}d", va='center', ha='center', color='white', fontweight='bold')
    ax.text(media_burocracia + media_plazo + (media_retraso_real/2), 0, f"{media_retraso_real:.1f}d", va='center', ha='center', color='white', fontweight='bold')
    
    # Estilizado del gráfico
    ax.set_xlabel("Días Transcurridos")
    ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.2), ncol=3)
    ax.set_xlim(0, media_burocracia + media_plazo + media_retraso_real + 5)
    plt.tight_layout()
    
    # Inyectar el gráfico directamente en la página web de Streamlit
    st.pyplot(fig)
    
    st.write("---")
    
    # --- BOXPLOT: DETECCIÓN DE CLIENTES TÓXICOS ---
    st.subheader("🕵️ Distribución de Retrasos (Caza de Anomalías)")
    st.markdown("El siguiente gráfico te muestra dónde se concentran la mayoría de los retrasos y los casos extremos de clientes que destruyen tu liquidez.")
    
    fig_box, ax_box = plt.subplots(figsize=(10, 3.5))
    # Usamos un diagrama de caja para ver la dispersión de Dias_Retraso
    sns.boxplot(x=df_h['Dias_Retraso'], ax=ax_box, color="#9467bd", fliersize=4)
    ax_box.set_xlabel("Días de Retraso (Valores negativos = Pago Adelantado)")
    ax_box.set_title("Dispersión Global de Retrasos en Facturas")
    
    st.pyplot(fig_box)

    # 💡 NUEVA LOGICA: Análisis cualitativo y estratégico de la dispersión
    st.markdown("""
    **💡 Interpretación Lean de la Dispersión:**
    * **Bloque Izquierdo (Negativos):** Representa la eficiencia del *Pronto Pago*. Clientes que inyectan liquidez adelantada al negocio pagando antes del vencimiento formal.
    * **Bloque Derecho (Outliers a más de 50 días):** Representa el *Desperdicio (Waste)* del flujo. Cuentas críticas estancadas que rompen el ciclo operativo y requieren acciones inmediatas de recobro.
    """)

# ==================================================
# PESTAÑA 3: AUTOMATIZACIÓN Y ALERTAS (ACCIÓN LEAN)
# ==================================================
with tab3:
    st.header("🎯 Automatización y Alertas Operativas")
    st.markdown("Herramientas de priorización basadas en el Principio de Pareto para enfocar los esfuerzos de recobro y liberar capital inmovilizado.")
    st.write("---")
    
    # Preparamos los datos históricos de retrasos reales (solo retrasos > 0)
    df_retrasos = df[(df['clear_date'].notna()) & (df['Dias_Retraso'] > 0)].copy()
    
    # 1. --- ANÁLISIS DE PARETO (REGLA 80/20) ---
    st.subheader("📊 Ley de Pareto: El 80% del Problema")
    st.markdown("La metodología Lean exige enfoque. Este análisis aísla de forma automática a los pocos clientes que acumulan el grueso de tus días de retraso totales.")
    
    # Agrupamos el total de días de retraso acumulados por cliente
    pareto_client = df_retrasos.groupby('name_customer')['Dias_Retraso'].sum().reset_index()
    pareto_client = pareto_client.sort_values(by='Dias_Retraso', ascending=False)
    
    # Calculamos el porcentaje acumulado
    pareto_client['%_Acumulado'] = (pareto_client['Dias_Retraso'].cumsum() / pareto_client['Dias_Retraso'].sum()) * 100
    
    # Filtramos los clientes que están dentro del top que genera hasta el 80% del impacto
    clientes_criticos_80 = pareto_client[pareto_client['%_Acumulado'] <= 85].copy()
    
    # Renombramos columnas para que la tabla luzca impecable en la interfaz
    clientes_criticos_80.columns = ["Nombre del Cliente", "Días de Retraso Acumulados", "Impacto Acumulado (%)"]
    
    # Mostramos la tabla dinámica estilizada
    st.dataframe(
        clientes_criticos_80.style.format({
            'Días de Retraso Acumulados': '{:,.0f}', 
            'Impacto Acumulado (%)': '{:.1f}%'
        }),
        hide_index=True,
        use_container_width=True
    )
    
    st.error(f"🚨 **Alerta de Operaciones:** Tienes **{len(clientes_criticos_80)} clientes críticos** bajo el foco de Pareto. Concentrar las reclamaciones exclusivamente en este listado solucionará más del 80% de las ineficiencias de cobro de la empresa.")
    
    st.write("---")
    
    # 2. --- FILTRO INTERACTIVO Y EXPEDIENTE DE CLIENTE (SIDEBAR) ---
    st.subheader("🔍 Expediente Comercial y Riesgo de Caja")
    st.markdown("Utiliza el buscador avanzado de la barra lateral izquierda para realizar una auditoría individualizada.")
    
    # --- MOTOR DE BÚSQUEDA POR COINCIDENCIA EN LA BARRA LATERAL ---
    st.sidebar.markdown("---")
    st.sidebar.write("### 🔍 Buscador Avanzado de Clientes")
    
    # 1. Caja de texto libre para que el usuario escriba lo que quiera
    termino_busqueda = st.sidebar.text_input(
        "Escribe el nombre (o parte de él):",
        value="",
        placeholder="Ej: wal o heinz..."
    )
    
    # Obtener la lista única de clientes
    lista_clientes_completa = sorted(df['name_customer'].dropna().unique())
    
    # 2. Filtrar la lista de clientes según lo que vaya escribiendo el usuario (insensible a mayúsculas)
    if termino_busqueda:
        clientes_filtrados = [
            c for c in lista_clientes_completa 
            if termino_busqueda.lower() in c.lower()
        ]
    else:
        clientes_filtrados = lista_clientes_completa
        
    # 3. Desplegable dinámico que se adapta a la búsqueda
    if len(clientes_filtrados) == 0:
        st.sidebar.warning("⚠️ No se encontraron coincidencias.")
        # Si no encuentra nada, por seguridad dejamos el primero de la lista global
        cliente_seleccionado = lista_clientes_completa[0] 
    else:
        cliente_seleccionado = st.sidebar.selectbox(
            "🎯 Selecciona el cliente exacto:",
            options=clientes_filtrados
        )
    # -------------------------------------------------------------
    
    # Filtramos los datos del cliente seleccionado finalmente
    df_cliente = df[df['name_customer'] == cliente_seleccionado]
    
    # Separamos su comportamiento histórico (cobrado) de sus facturas vivas (abiertas)
    historico_cliente = df_cliente[df_cliente['clear_date'].notna()]
    vivas_cliente = df_cliente[df_cliente['clear_date'].isna()]
    
    # Pintamos la ficha del cliente maquetada en dos columnas
    c_col1, c_col2 = st.columns(2)
    
    with c_col1:
        st.info(f"### 📋 Historial Comercial: {cliente_seleccionado}")
        st.write(f"• **Facturas históricas pagadas y cerradas:** {len(historico_cliente)} transacciones.")
        if len(historico_cliente) > 0:
            retraso_medio_cliente = historico_cliente['Dias_Retraso'].mean()
            if retraso_medio_cliente > 0:
                st.write(f"• **Comportamiento de Pago:** Se retrasa un promedio de `{retraso_medio_cliente:.1f}` días.")
            else:
                st.write(f"• **Comportamiento de Pago:** Cliente excelente. Paga con un adelanto medio de `{abs(retraso_medio_cliente):.1f}` días (Pronto Pago).")
        else:
            st.write("• **Comportamiento de Pago:** Sin registros históricos cerrados.")
            
    with c_col2:
        st.warning("### 💸 Capital en Riesgo Actual")
        st.write(f"• **Facturas vivas actualmente pendientes de cobro:** {len(vivas_cliente)} documentos.")
        st.write(f"• **Total dinero retenido en la calle:** `${vivas_cliente['total_open_amount'].sum():,.2f}`")