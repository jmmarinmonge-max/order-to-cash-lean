Order-to-Cash Lean: Análisis y Optimización del Ciclo de Cobro

🎯 Propósito del Proyecto

Este proyecto de análisis de datos con Python tiene como objetivo identificar y reducir los "atascos" financieros en el proceso Order-to-Cash. Mediante la aplicación de Value Stream Mapping, el dashboard separa las actividades de valor de la burocracia interna, permitiendo una reducción efectiva del ciclo de cobro y mejorando la liquidez del negocio.

🚀 Acceso al Dashboard

Puedes interactuar con el dashboard en tiempo real aquí:
https://jmmarinmonge-max-order-to-cash-lean-app-1cac34.streamlit.app/

🛠️ Stack Tecnológico

Lenguaje: Python 3.10+

Framework: Streamlit (Interfaz interactiva y despliegue cloud)

Procesamiento y Análisis: Pandas, NumPy

Visualización: Matplotlib, Seaborn

Metodología: Lean Six Sigma (Value Stream Mapping & Análisis Pareto)

📊 Características Principales

El dashboard está diseñado bajo un flujo de trabajo automatizado y se estructura en tres secciones críticas:

KPI Vista General: Visión estratégica del Capital Inmovilizado, Lead Time medio de cobro y porcentaje de facturas con retraso.

Value Stream Mapping: Análisis visual de los tiempos de espera entre estados (Creación → Contabilización → Vencimiento → Cobro), identificando ineficiencias mediante diagramas de flujo y boxplots de retraso por cliente.

Automatización y Alertas: Aplicación del Principio de Pareto para filtrar clientes de alto impacto en el retraso y herramientas de filtrado interactivo para seguimiento predictivo de pagos.

⚙️ Estructura del Pipeline

El proyecto sigue un proceso automatizado de tres fases:

Limpieza y Transformación: Normalización de fechas complejas y tratamiento de valores nulos para facturas abiertas.

Cálculo de Métricas Lean: Aplicación de lógica de negocio para determinar Lead Time Total, DSO (Days Sales Outstanding) y Tiempo de Espera Interno.

Visualización Dinámica: Generación de gráficos orientados a la detección de cuellos de botella.

🚀 Instrucciones de Ejecución

# Clonar el repositorio
git clone https://github.com/jmmarinmonge-max/order-to-cash-lean.git

# Instalar dependencias
pip install -r requirements.txt

# Iniciar la aplicación
streamlit run app.py