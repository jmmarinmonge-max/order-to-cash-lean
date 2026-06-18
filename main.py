import pandas as pd
from src.data_processing import (
    cargar_y_explorar_dataset, 
    analizar_tipos_de_datos, 
    analizar_valores_nulos,
    eliminar_columnas_irrelevantes,
    transformar_fechas,
    calcular_lead_times_lean,
    analizar_metricas_descriptivas,
    segmentar_facturas_lean,
    analizar_clientes_criticos
)

# NUEVA FUNCIÓN: Permite que app.py importe los datos crudos de forma limpia
def cargar_datos_fuente():
    ruta = "data/customer_invoices.csv"
    return pd.read_csv(ruta)

# Este bloque se ejecutará SOLO si ejecutas "python main.py" en la terminal
if __name__ == "__main__":
    # Llamamos a la función de carga
    df_inicial = cargar_datos_fuente()
    
    # Bloque de Diagnóstico Inicial
    analizar_tipos_de_datos(df_inicial)
    analizar_valores_nulos(df_inicial)
    
    # Bloque de Transformación en Cadena
    df_filtrado = eliminar_columnas_irrelevantes(df_inicial)
    df_fechas = transformar_fechas(df_filtrado)
    df_final = calcular_lead_times_lean(df_fechas)
    
    # Análisis Analítico y Segmentación
    analizar_metricas_descriptivas(df_final)
    df_historico, df_vivas = segmentar_facturas_lean(df_final)
    
    # Paso 9: Identificación de Clientes Críticos
    analizar_clientes_criticos(df_historico, df_vivas)