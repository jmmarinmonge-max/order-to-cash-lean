-- FASE 1: ANÁLISIS Y TRANSFORMACIÓN EN MYSQL WORKBENCH

-- 1. Importación de datos y verificación

use ecommerce_lectura;
show tables;
select * from sesiones_embudo limit 10;

-- 2. Calidad de datos

	-- Identificación de valores nulos

select
	count(*) as conteo
from
	sesiones_embudo
where 
	id_usuario is null or
    valor_carrito is null;
    
	-- Revisión de valores atípicos 

select 
	min(valor_carrito) as minimo,
    max(valor_carrito) as maximo
from sesiones_embudo; -- Sin valores negativos o extremadamente altos

	-- Revisión de integridad referencial

select 
	t1.*
from
	sesiones_embudo as t1
left join 
	usuarios as t2
on 
	t1.id_usuario = t2.id_usuario
where
	t2.id_usuario is null; -- Sin sesiones con usuario asignado, es decir, sin filas huérfanas

	-- Transformación de variables

set sql_safe_updates = 0;

update 
	sesiones_embudo 
set 
	paso_final_embudo = upper(paso_final_embudo); -- Me aseguro de que los registros se cuenten como una sola categoría

select 
	sum(es_compra_finalizada) as compras_totales
from
	sesiones_embudo; -- Verificamos la sumatoria de la columna es_compra_finalizada

select
    count(id_sesion) as Total_Sesiones_Iniciadas,
    sum(es_compra_finalizada) as Compras_Finalizadas,
    (sum(es_compra_finalizada) / count(id_sesion)) * 100 as Tasa_Conversion_Porcentaje,
    (1 - (sum(es_compra_finalizada) / count(id_sesion))) * 100 as Tasa_Abandono_Porcentaje
from
    sesiones_embudo; -- Calculamos tasa de conversión y de abandono

	-- Modelización, muestro fuga de usuarios paso a paso

with 	pasos_ordenados as (
			select
				paso_final_embudo,
                case paso_final_embudo
					when 'CARRITO' then 1
                    when 'ENVIO' then 2
                    when 'PAGO' then 3
                    when 'COMPRA' then 4
					else 0
				end as orden_paso
			from sesiones_embudo
)
select
	'CARRITO' as paso,
    (select count(id_sesion) from sesiones_embudo) as sesiones_alcanzadas,
    1 as orden_paso
union all
select
	'ENVIO' as paso,
    (select count(id_sesion) from sesiones_embudo where paso_final_embudo in ('ENVIO','PAGO','COMPRA')) as sesiones_alcanzadas,
    2 as orden_paso
union all
select
	'PAGO' as paso,
    (select count(id_sesion) from sesiones_embudo where paso_final_embudo in ('PAGO','COMPRA')) as sesiones_alcanzadas,
    3 as orden_paso
union all
select 
	'COMPRA' as paso,
    (select count(id_sesion) from sesiones_embudo where paso_final_embudo = 'COMPRA') as sesiones_alcanzadas,
    4 as orden_paso
order by orden_paso;

	-- Evaluación y descarte de hipótesis

select 
	dispositivo_predeterminado,
    count(id_sesion) as total_sesiones,
    sum(case when paso_final_embudo = 'COMPRA' then 1 else 0 end) as compras_finalizadas,
    (sum(case when paso_final_embudo = 'COMPRA' then 1 else 0 end) / count(id_sesion)) * 100 as tasa_conversion
from 
	sesiones_embudo as se
inner join
	usuarios as u on se.id_usuario = u.id_usuario
where 
	paso_final_embudo in ('ENVIO','PAGO','COMPRA')
group by
	dispositivo_predeterminado
order by
	tasa_conversion; -- Se descarta la hipótesis del problema de la UX para confirmar que el problema está en el coste/opción del paso ENVIO - PAGO

-- Segmentación Clave (Confirmación de la Hipótesis del Costo de Envío)

select
    tipo_envio,
    count(id_sesion) as Sesiones_Totales_Tipo_Envio,
    sum(case when paso_final_embudo = 'COMPRA' then 1 else 0 end) as Compras_Finalizadas,
    (SUM(CASE WHEN paso_final_embudo = 'COMPRA' then 1 else 0 end) / COUNT(id_sesion)) * 100 as Tasa_Conversion_Tipo_Envio
from
    sesiones_embudo
group by
    tipo_envio
order by
    Tasa_Conversion_Tipo_Envio desc;
    
	-- Implantación Tableau

select
	se.id_sesion,
    se.fecha,
    se.paso_final_embudo as paso_final_abandono,
    se.es_compra_finalizada as compra_exitosa,
    se.valor_carrito as valor_medio_carrito,
    se.tipo_envio as tipo_envio_elegido,
    se.costo_envio as coste_envio_aplicado,
    u.ciudad as ciudad_usuario,
    u.dispositivo_predeterminado as dispositivo_acceso
from
	sesiones_embudo as se
inner join
	usuarios as u on se.id_usuario = u.id_usuario
order by
	se.fecha,
    se.id_sesion;