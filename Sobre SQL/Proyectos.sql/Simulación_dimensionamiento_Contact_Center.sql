-- 1. Importación y verificación de datos

use cc_diario_db;
select * from llamadas_diarias;
describe llamadas_diarias;
select count(*) as total_registros from llamadas_diarias;

-- 2. Calidad de datos

	-- Revisión de valores duplicados
        
select 
	fecha,
    motivo,
    count(*)
from 
	llamadas_diarias
group by 1,2
having count(*) > 1; -- Sin valores duplicados

	-- Revisión de días con volumen negativo o nulos

select 
	* 
from 
	llamadas_diarias
where 
	volumen <= 0 or volumen is null; -- Sin volúmenes negativos o nulos

	-- Revisión de valores atípicos, como días con volumen extremadamente superior a la media

select 
	* 
from 
	llamadas_diarias 
where 
	volumen > (select avg(volumen) * 3 as volumen_atipico from llamadas_diarias); -- Sin días con volumen atípico

-- 3. Transformación de variables

	-- Creamos vista procesada para su lectura posterior en Excel

create view v_prevision_diaria as    
select 
    fecha,
    dayname(fecha) as nombre_dia, 
    sum(volumen) as total_llamadas,
    round(avg(aht_seg), 2) as aht_promedio_dia
from llamadas_diarias
group by fecha
order by fecha asc;

	-- Comprobar resultado de la vista

select * from v_prevision_diaria;

-- 4. Evaluación

	-- Evaluar el volumen promedio por día de la semana para confirmar que hay patrón semanal

select 
    nombre_dia, 
    round(avg(total_llamadas), 0) as promedio_llamadas
from 
	v_prevision_diaria
group by 
	nombre_dia
order by 
	field(nombre_dia, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

-- 5. Implantación

	-- Script de actualización para el Dashboard - Extrae solo los últimos 30 días para comparar Real vs Forecast

select 
	* 
from 
	v_prevision_diaria 
where 
	fecha >= (select date_sub(max(fecha), interval 30 day) from llamadas_diarias);