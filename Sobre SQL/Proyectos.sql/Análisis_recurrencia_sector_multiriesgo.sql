-- 1. Importación de datos

create database proyecto_asistia;
use proyecto_asistia;

create table siniestros (
	id_siniestro varchar(20) primary key,
    feha_apertura varchar(50), 
    mes_año varchar(10),
    gremio_principal varchar(50),
    provincia varchar(50),
    tipo_asegurado varchar(50),
    coste_presupuestado decimal(10,2),
    coste_final_Facturado decimal(10,2),
    segunda_visita varchar(5),
    motivo_desviacion varchar(100),
    dias_gestion int,
    satisfaccion_cliente int
);

	-- Cargo los datos desde la función de Data Import Wizard de MySQL Workbench
    -- El resultado es una tabla vacía, debido al formato de los datos (;)
    -- Transformo con bloc de notas el archivo cambiando las (,) de los números por (.) y cambiando los (;) por (,)

-- 2. Calidad de datos
    
describe siniestros; -- Compruebo que el campo fecha_apertura es de tipo incorrecto

	-- Convierto la columna feha_apertura a formato datetime real

set sql_safe_updates = 0;

update siniestros 
set feha_apertura = str_to_date(feha_apertura, '%d/%m/%Y %H:%i');

-- Renombrar campo coste_final_Facturado y feha_apertura

alter table siniestros rename column coste_final_Facturado to coste_final_facturado;
alter table siniestros rename column feha_apertura to fecha_apertura;

	-- Verifico si hay registros con costes incoherentes (ej. negativos o cero)
select 
	* 
from 
	siniestros 
where 
	coste_final_facturado <= 0;

-- 3. Transformación de variables

	-- Creo vista para mostrar desviación económica, recurrencia, y satisfacción del cliente

create view v_analisis_siniestros as
select 
	*,
    (coste_final_facturado - coste_presupuestado) as desviacion_coste,
    case when segunda_visita = 'SI' then 1 else 0 end as recurrencia,
    case
		when satisfaccion_cliente >= 4 then 'alta'
        when satisfaccion_cliente = 3 then 'media'
        else 'baja'
	end as categoria_satisfaccion
from
	siniestros;
 
 -- 4. Modelización
 
 select * from v_analisis_siniestros; -- Saco output a archivo .csv nombrado como 'vista_analisis_siniestros.csv' para conectarlo con Tableau
