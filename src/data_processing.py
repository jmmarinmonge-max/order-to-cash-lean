# Importamos la librería Pandas para el manejo de tablas
import pandas as pd

def cargar_y_explorar_dataset():
    # Definimos la ruta de nuestro archivo CSV
    ruta = "data/customer_invoices.csv"
    
    # CARGA: Leemos el archivo y lo guardamos en el DataFrame 'df'
    df = pd.read_csv(ruta)
    
    print("\n" + "="*50)
    print("🚀 PASO 1: EXPLORACIÓN INICIAL EN LA TERMINAL")
    print("="*50)
    
    # 1. df.shape -> Nos dice las dimensiones (Filas, Columnas)
    dimensiones = df.shape
    print(f"• Dimensiones del archivo (Filas, Columnas): {dimensiones}")
    print(f"  - Total de registros a procesar: {dimensiones[0]:,}")
    print(f"  - Total de variables/columnas: {dimensiones[1]}")
    print("-"*50)
    
    # 2. df.columns -> Nos da una lista con los nombres de todas las columnas
    print("• Nombres de las columnas del dataset:")
    print(df.columns)
    print("-"*50)
    
    # 3. df.head() -> Nos muestra las primeras filas para ver el aspecto de los datos
    # Le pasamos un 3 para ver solo las 3 primeras filas y no saturar la pantalla
    print("• Vista previa de las primeras 3 filas:")
    print(df.head(3))
    print("="*50 + "\n")

def analizar_tipos_de_datos(df):
    print("\n" + "="*50)
    print("🔍 PASO 2: ANÁLISIS DE TIPOS DE DATOS (DTYPES)")
    print("="*50)
    
    # df.dtypes -> Nos dice el tipo de dato de cada columna:
    # int64 (número entero), float64 (número con decimales), object (texto)
    print("• Tipo de dato asignado a cada columna por Pandas:")
    print(df.dtypes)
    print("="*50 + "\n")

def analizar_valores_nulos(df):
    print("\n" + "="*50)
    print("❓ PASO 3: ANÁLISIS DE VALORES NULOS (DATOS FALTANTES)")
    print("="*50)
    
    # df.isna() -> Revisa toda la tabla y marca True donde falta un dato y False donde sí hay dato.
    # .sum() -> Suma todos los True para decirnos cuántos nulos hay exactamente por columna.
    print("• Cantidad de valores nulos por columna:")
    print(df.isna().sum())
    print("="*50 + "\n")

def eliminar_columnas_irrelevantes(df):
    print("\n" + "="*50)
    print("🧹 PASO 4: ELIMINACIÓN DE COLUMNAS IRRELEVANTES")
    print("="*50)
    
    # Creamos una lista con los nombres de las columnas que queremos borrar
    # Vamos a quitar 'area_business' porque está vacía (50.000 nulos)
    columnas_a_eliminar = ['area_business']
    
    # df.drop() elimina las columnas seleccionadas.
    # axis=1 le dice a Pandas que busque en las COLUMNAS (si pusiéramos axis=0 buscaría filas).
    df_limpio = df.drop(columns=columnas_a_eliminar)
    
    print(f"• Columnas antes de borrar: {df.shape[1]}")
    print(f"• Columnas después de borrar: {df_limpio.shape[1]}")
    print(f"• Se ha eliminado correctamente la columna: {columnas_a_eliminar}")
    print("="*50 + "\n")
    
    # Devolvemos la nueva tabla limpia para que la use el siguiente paso
    return df_limpio

import pandas as pd
import numpy as np

import pandas as pd

def transformar_fechas(df):
    print("\n" + "="*50)
    print("📅 PASO 5: CONVERSION DE FECHAS (FORMATO SEGURO INDIVIDUAL)")
    print("="*50)
    
    df_fechas = df.copy()
    
    # 1. document_create_date viene como entero limpio (20200125) -> Formato '%Y%m%d'
    df_fechas['document_create_date'] = pd.to_datetime(
        df_fechas['document_create_date'].astype(str), 
        format='%Y%m%d', 
        errors='coerce'
    )
    
    # 2. due_in_date viene como float (20200210.0) -> Quitamos el '.0' pasándolo a entero y luego a fecha
    s_due_limpio = df_fechas['due_in_date'].astype(str).str.split('.').str[0].str.strip()
    df_fechas['due_in_date'] = pd.to_datetime(s_due_limpio, format='%Y%m%d', errors='coerce')
    
    # 3. clear_date viene como string con guiones y tiempo -> Formato '%Y-%m-%d %H:%M:%S'
    df_fechas['clear_date'] = pd.to_datetime(
        df_fechas['clear_date'], 
        format='%Y-%m-%d %H:%M:%S', 
        errors='coerce'
    )
    
    # 4. NUEVO: posting_date viene como string simple (2020-01-26) -> Formato '%Y-%m-%d'
    df_fechas['posting_date'] = pd.to_datetime(
        df_fechas['posting_date'], 
        format='%Y-%m-%d', 
        errors='coerce'
    )
    
    print("• Comprobación de tipos de datos corregidos:")
    print(df_fechas[['document_create_date', 'due_in_date', 'clear_date', 'posting_date']].dtypes)
    print("-"*50)
    
    facturas_con_fecha = df_fechas[df_fechas['clear_date'].notna()]
    print(f"• Control de calidad: Facturas cobradas recuperadas: {len(facturas_con_fecha):,}")
    print("="*50 + "\n")
    
    return df_fechas

def calcular_lead_times_lean(df):
    print("\n" + "="*50)
    print("⚙️ PASO 6: CÁLCULO DE LEAD TIMES (MÉTRICAS LEAN)")
    print("="*50)
    
    df_tiempos = df.copy()
    
    # 1. Calculamos el tiempo de espera interno
    df_tiempos['Dias_Burocracia'] = (df_tiempos['posting_date'] - df_tiempos['document_create_date']).dt.days
    
    # 2. REGLA DE NEGOCIO / SANEAMIENTO LEAN:
    # Si hay valores negativos por errores de registro en el ERP, los topamos en 0 días.
    df_tiempos['Dias_Burocracia'] = df_tiempos['Dias_Burocracia'].clip(lower=0)
    
    # 3. Calculamos los tiempos de cara al cliente
    df_tiempos['Dias_Pago'] = (df_tiempos['clear_date'] - df_tiempos['document_create_date']).dt.days
    df_tiempos['Dias_Retraso'] = (df_tiempos['clear_date'] - df_tiempos['due_in_date']).dt.days
    
    print("• Vista previa de las métricas Lean (Burocracia vs Cliente):")
    print(df_tiempos[['document_create_date', 'posting_date', 'clear_date', 'Dias_Burocracia', 'Dias_Pago', 'Dias_Retraso']].head(3))
    print("="*50 + "\n")
    
    return df_tiempos

def analizar_metricas_descriptivas(df):
    print("\n" + "="*50)
    print("📊 PASO 7: ESTADÍSTICAS DESCRIPTIVAS DE LOS LEAD TIMES")
    print("="*50)
    
    # NUEVO: Añadimos 'Dias_Burocracia' a la lista para que también lo analice
    columnas_interes = ['Dias_Burocracia', 'Dias_Pago', 'Dias_Retraso']
    
    # df.describe() calculará automáticamente count, mean, std, min, max, etc. para las tres columnas
    resumen_estadistico = df[columnas_interes].describe()
    
    print("• Resumen estadístico del comportamiento de cobros:")
    print(resumen_estadistico)
    print("="*50 + "\n")

def segmentar_facturas_lean(df):
    print("\n" + "="*50)
    print("🎯 PASO 8: SEGMENTACIÓN LEAN (FACTURAS ABIERTAS VS COBRADAS)")
    print("="*50)
    
    # 1. Filtramos las facturas ABIERTAS (donde clear_date está vacío / NaT)
    facturas_abiertas = df[df['clear_date'].isna()]
    
    # 2. Filtramos las facturas COBRADAS/HISTÓRICAS (donde clear_date SÍ tiene fecha)
    # El símbolo ~ significa "lo contrario", es decir, que NO sea nulo
    facturas_cobradas = df[~df['clear_date'].isna()]
    
    # 3. Calculamos los volúmenes y el dinero que representa cada grupo
    total_registros = len(df)
    cant_abiertas = len(facturas_abiertas)
    cant_cobradas = len(facturas_cobradas)
    
    # Asumimos que la columna del importe de la factura se llama 'total_open_amount'
    # (vimos ese nombre en tu diagnóstico de nulos)
    dinero_en_riesgo = facturas_abiertas['total_open_amount'].sum()
    dinero_cobrado = facturas_cobradas['total_open_amount'].sum()
    
    print(f"• Volumen Total del Dataset: {total_registros:,} facturas.")
    print(f"• Facturas Históricas (Cobradas): {cant_cobradas:,} ({cant_cobradas/total_registros*100:.1f}%)")
    print(f"  - Total dinero ya ingresado: {dinero_cobrado:,.2f}")
    print(f"• Facturas Vivas (Abiertas / Pendientes): {cant_abiertas:,} ({cant_abiertas/total_registros*100:.1f}%)")
    print(f"  - CAPITAL COMPROMETIDO (Dinero en la calle): {dinero_en_riesgo:,.2f}")
    print("="*50 + "\n")
    
    # Devolvemos ambas sub-tablas por si las necesitamos para análisis específicos más adelante
    return facturas_cobradas, facturas_abiertas

def analizar_clientes_criticos(df_historico, df_vivas):
    print("\n" + "="*50)
    print("👥 PASO 9: ANÁLISIS DE CLIENTES CRÍTICOS (GROUPBY)")
    print("="*50)
    
    # 1. Analizamos el HISTÓRICO: ¿Quién se retrasa más de media?
    # Agrupamos por nombre de cliente y calculamos la media de Dias_Retraso
    top_retrasos = df_historico.groupby('name_customer')['Dias_Retraso'].mean().reset_index()
    # Ordenamos de mayor a menor retraso y nos quedamos con los 3 peores
    top_retrasos = top_retrasos.sort_values(by='Dias_Retraso', ascending=False).head(3)
    
    # 2. Analizamos el RIESGO VIVO: ¿Quién nos debe más dinero ahora mismo?
    # Agrupamos por cliente y sumamos su importe pendiente
    top_deuda = df_vivas.groupby('name_customer')['total_open_amount'].sum().reset_index()
    # Ordenamos de mayor a menor dinero retenido y nos quedamos con los 3 primeros
    top_deuda = top_deuda.sort_values(by='total_open_amount', ascending=False).head(3)
    
    print("• TOP 3: Clientes históricos con mayor retraso promedio (días):")
    print(top_retrasos.to_string(index=False))
    print("-"*50)
    
    print("• TOP 3: Clientes vivos con más capital retenido (dinero en la calle):")
    # Formateamos el dinero para que sea legible en la terminal
    top_deuda['total_open_amount'] = top_deuda['total_open_amount'].map('{:,.2f}'.format)
    print(top_deuda.to_string(index=False))
    print("="*50 + "\n")