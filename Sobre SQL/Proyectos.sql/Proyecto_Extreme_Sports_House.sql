-- SE TRATA DE UN PROYECTO GUIADO DEL MÓDULO DE SQL DE DS4B

-- SPRINT SEMANA 2 - TAREA 1
---------------------------------------------

-- Importa la bbdd a partir de dump: caso.sql

-- Activala como la bbdd por defecto

use caso;


-- Revisa el contenido de las 4 tablas

select * from ventas;
select * from productos;
select * from canales;
select * from tiendas;


-- ¿Cuantos registos tiene la tabla ventas?

select count(*) from ventas;


-- Revisa el tipo de los datos, ¿ves algo raro?
#Hay que cambiar la fecha a tipo Date, lo dejamos apuntado


-- ¿Está al nivel que necesitamos? tienda - producto - canal – fecha (no tiene que haber duplicados)

select count(*) as conteo
from ventas
group by id_tienda, id_prod, id_canal, fecha
having conteo > 1;


-- Si hay duplicados muéstralos para identificar algún caso concreto

select id_tienda, id_prod, id_canal, fecha, count(*) as conteo
from ventas
group by id_tienda, id_prod, id_canal, fecha
having conteo > 1
order by id_tienda, id_prod, id_canal, fecha;


-- Revisa un par de ellos

select *
from ventas
where id_tienda = 1115
  and id_prod = 127110
  and id_canal = 5
  and fecha = '22/12/2016';
  
select *
from ventas
where id_tienda = 1135
  and id_prod = 129180
  and id_canal = 5
  and fecha = '19/10/2017';

--Conclusión: es posible que la misma tienda haya hecho varios pedidos para el mismo producto el mismo día y a través del mismo canal.

-- Crea una nueva tabla de ventas_agr agregada a ese nivel, y además:
	-- Cambia la fecha a tipo date 
    -- (pista: usa la función de texto str_to_date con formato '%d/%m/%Y'. Ver: https://www.w3schools.com/sql/func_mysql_str_to_date.asp)
	-- Crea un campo facturación como la multiplicación de la cantidad por el precio_oferta
    
create table ventas_agr as
select str_to_date(fecha, '%d/%m/%Y') as fecha,
	   id_prod, id_tienda, id_canal,
       sum(cantidad) as cantidad,
       avg(precio_oficial) as precio_oficial,
       avg(precio_oferta) as precio_oferta,
       sum(cantidad) * avg(precio_oferta) as facturacion
from ventas
group by 1, 2, 3, 4;   
    
    
-- Revisa la nueva tabla creada

select * from ventas_agr;


-- Revisa cuantos registros tiene la nueva tabla

select count(*)
from ventas_agr; # tabla nueva con 134688 registros (sin duplicados)

select count(*)
from ventas; # tabla anterior con 149257 registros (tiene duplicados)




-- SPRINT SEMANA 2 - TAREA 2
---------------------------------------------

-- Crea un diagrama ER para ver cómo está relacionada la nueva tabla



-- Haz un join con la tabla productos para comprobar que aunque no esté relacionada se pueden hacer igualmente las consultas

select *
from ventas_agr as v inner join productos as p on v.id_prod = p.id_prod;


-- Pero vamos a hacerlo bien. Modifica la tabla ventas_agr para:
	--  Incluir un nuevo campo clave incremental llamado id_venta
	--  Que id_prod sea un FK con su tabla y campo correspondiente
	--  Que id_tienda sea un FK con su tabla y campo correspondiente
	--  Que id_canal sea un FK con su tabla y campo correspondiente

alter table ventas_agr add id_venta int auto_increment primary key,
					   add foreign key(id_prod) references productos(id_prod) on delete cascade,
                       add foreign key(id_tienda) references tiendas(id_tienda) on delete cascade,
                       add foreign key(id_canal) references canales(id_canal) on delete cascade;


-- Vuelve a crear el diagrama ER para ver cómo se relaciona ahora la nueva tabla
# Hecho desde DataBase - Reverse Engineer


-- Crea una vista sobre la tabla ventas_agr que incluya el pedido
	-- (Consideramos que será el mismo pedido cuando se haya hecho en la misma fecha, por la misma tienda y con el mismo canal)
-- visualizamos la tabla ventas_agr
select *
from ventas_agr;

-- Hay que crear un maestro que devuelva todas las combinaciones de fecha-tienda y canal (menos el producto porque en la 
-- tabla van cambiando y entendemos que todo lo que pase en la misma fecha, con misma tienda y mismo canal forma
-- parte del mismo pedido), agrupando estas combinaciones y asignando un valor a cada combinación. 
-- Una vez que tenga esa tabla temporal generada, volveré a la tabla original y haré left join por los tres campos
-- mencionados anteriormente para pegarle el identificador correspondiente creado anteriormente, que tiene que 
-- ser secuencial y lo haremos usando lo aprendido con los ranking (con row_number).

-- 1º Creamos el maestro de pedidos con un cte

with maestro_pedidos as (
	select fecha, id_tienda, id_canal, row_number() over() as id_pedido
    from ventas_agr
    group by fecha, id_tienda, id_canal)
select id_venta, id_pedido, v.fecha, v.id_prod, v.id_tienda, v.id_canal, cantidad, precio_oficial, precio_oferta, facturacion
from ventas_agr as v
	left join maestro_pedidos as m
    on (v.fecha = m.fecha) and (v.id_tienda = m.id_tienda) and (v.id_canal = m.id_canal);

-- 2ª Lo añadimos a una vista para no tener que repetir cada vez que necesitemos ejecutar esta consulta

create view v_ventas_agr_pedido as 
with maestro_pedidos as (
	select fecha, id_tienda, id_canal, row_number() over() as id_pedido
    from ventas_agr
    group by fecha, id_tienda, id_canal)
select id_venta, id_pedido, v.fecha, v.id_prod, v.id_tienda, v.id_canal, cantidad, precio_oficial, precio_oferta, facturacion
from ventas_agr as v
	left join maestro_pedidos as m
    on (v.fecha = m.fecha) and (v.id_tienda = m.id_tienda) and (v.id_canal = m.id_canal);
     
     
     
     
-- SPRINT SEMANA 3 - TAREA 1
---------------------------------------------

-- ¿Cuántos pedidos tenemos en nuestro histórico?

select count(distinct id_pedido)
from v_ventas_agr_pedido;

-- También se puede hacer así:

select max(id_pedido)
from v_ventas_agr_pedido;


-- ¿Desde qué día a qué dia tenemos datos?

select min(fecha) as primer_dia, max(fecha) as ult_dia
from v_ventas_agr_pedido;

-- También se puede hacer desde la tabla ventas_agr:

select min(fecha) as primer_dia, max(fecha) as ult_dia
from ventas_agr;


-- ¿Cuántos productos distintos tenemos en nuestro catálogo?

-- Vemos que hay productos con el mismo nombre pero con color diferente, y el id_prod cambia, por lo que haremos la consulta a nivel de id_prd

select *
from productos
order by producto;

-- Hacemos la consulta con id_prod

select count(distinct id_prod)
from productos; # 274 productos


-- ¿A cuántas tiendas distintas distribuimos?

select count(distinct id_tienda) from tiendas;



-- ¿A través de qué canales nos pueden hacer pedidos?

select distinct canal from canales;





-- SPRINT SEMANA 3 - TAREA 2
---------------------------------------------

-- Cuales son los 3 canales en los que más facturamos

select v.id_canal, c.canal, sum(v.facturacion) as facturacion_canal
from ventas_agr as v
	left join canales as c
    on v.id_canal = c.id_canal
group by v.id_canal
order by facturacion_canal desc
limit 3;


-- Cual ha sido la evolución mensual de la facturación por canal en los últimos 12 meses completos

-- Habría que hacer un group by de sum(facturacion) sobre mes y canal, o sea, la suma de la facturación por mes y canal.
-- Otra dificultad añadida es que tiene que ser de los últimos 12 meses completos, por lo que tendremos que revisar cuál es el último mes completo,
-- y establecer un filtro para que sea desde ese mes comppleto hasta el mismo mes del año pasado para que sean los 12 meses completos.

select id_canal, month(fecha) as mes, sum(facturacion) as facturacion_canal
from ventas_agr
group by id_canal, mes
order by id_canal, mes;

-- Realizo el filtro de fecha de meses completos a 12 meses

select *
from ventas_agr
where fecha BETWEEN '2017-07-01' and '2018-06-30';

-- Incluyo el filtro del where en la consulta anterior pero incluyendo el canal mediante un join

select v.id_canal, c.canal, month(fecha) as mes, sum(facturacion) as facturacion_canal
from ventas_agr as v
	left join canales as c
    on v.id_canal = c.id_canal
where fecha BETWEEN '2017-07-01' and '2018-06-30'
group by v.id_canal, mes
order by v.id_canal, c.canal, mes;


-- Localiza el nombre de nuestros 50 mejores clientes (tiendas con mayor facturación)

select v.id_tienda, t.nombre_tienda, sum(facturacion) as facturacion_por_tienda
from ventas_agr as v
	left join tiendas as t
    on v.id_tienda = t.id_tienda
group by v.id_tienda, t.nombre_tienda
order by facturacion_por_tienda desc
limit 50;


-- Analiza la evolución de la facturación de cada país por trimestre desde 2017	

-- TRAMPAS EN LA PREGUNTA A TENER EN CUENTA:
	-- El filtro nos lo piden desde 2017
	-- Los datos nos lo piden por trimestre y tienen que ser completos
	-- Hay que hacer con datos de trimestres enteros (hasta el 30/06/2018)
	-- Nos piden que lo hagamos por paises, pero esta información no la tenemos en la tabla ventas_agr, por lo que habrá que cruzar tablas

select t.pais, year(fecha) as año, quarter(fecha) as trimestre, sum(facturacion) as facturacion_trimestre 
from ventas_agr as v
	left join tiendas as t
    on v.id_tienda = t.id_tienda
where fecha between '2017-01-01' and '2018-06-30'
group by pais, año, trimestre
order by pais, año, trimestre;

-- SPRINT SEMANA 4 - TAREA 1
---------------------------------------------

-- Encuentra los 20 productos en los que sacamos mayor margen ((precio - coste) / coste * 100) en cada línea de producto

-- Primero creamos la tabla temporal para la creación del margen en toda la tabla productos

with tabla_margen as (
	select *, round(((precio - coste) / coste) * 100,2) as margen
    from productos)

-- Y ahora ya podemos seleccionar los datos necesarios para responder a la pregunta de negocio

select *
from (select id_prod, linea, producto, margen, row_number() over(partition by linea order by margen desc) as ranking
	from tabla_margen) as ranking
where ranking <= 20;


-- Encuentra aquellos productos (su identificador) en los que estemos haciendo descuentos (en porcentaje) superiores al valor de decuento que deja por debajo al 90% de los descuentos
-- Osea, calcular el percentil 90, para saber qué productos están por debajo y por encima del percentil

-- Visualizamos la tabla y vemos que no está al nivel requerido (a nivel de producto), porque si ordenamos por id_producto, 
-- vemos qué hay valores repetidos

select *
from ventas_agr;

-- Entonces habría que resolverlo por pasos:
	-- 1º agregar por producto y calcular el precio oficial y precio oferta con alguna función de agregación
    -- 2º calcular la variable de descuento
    -- 3º posicionarla 
    -- 4º identificar aquellos productos con descuentos superiores al percentil indicado

-- Paso 1: Poner la tabla al nivel que necesitamos agregando por producto y calculando el precio oficial y precio oferta con función agregación avg

select id_prod, avg(precio_oficial) as precio_oficial_medio, avg(precio_oferta) as precio_oferta_medio
from ventas_agr
group by id_prod;

-- Paso 2: Calcular la métrica del descuento

select *, round(((precio_oficial_medio - precio_oferta_medio) / precio_oficial_medio) * 100, 2) as descuento
from (select id_prod, avg(precio_oficial) as precio_oficial_medio, avg(precio_oferta) as precio_oferta_medio
	from ventas_agr
	group by id_prod) as nivel_producto
;

with tabla_descuento as (
	select *, round(((precio_oficial_medio - precio_oferta_medio) / precio_oficial_medio) * 100, 2) as descuento
	from (select id_prod, avg(precio_oficial) as precio_oficial_medio, avg(precio_oferta) as precio_oferta_medio
		from ventas_agr
		group by id_prod) as nivel_producto)


-- Paso 3: Posicionarla para localizar aquel valor que está por debajo del percentil indicado, usando una función ventana cume_dist() 

select descuento, cume_dist() over(order by descuento) as dist_acum 
from tabla_descuento;

-- Paso 4: Identificamos aquellos productos que estén por encima del valor de dist_acum del 90%, es decir, de 0.9
-- Por tanto cambiamos la selección descuento por tipo de producto para tener los productos y hacer un where para filtrar por 0.9
-- El problema que vamos a tener con el where es que se ejecuta antes que el select en orden de ejecución
-- Así que tendremos que hacer una subconsulta

with tabla_descuento as (
	select *, round(((precio_oficial_medio - precio_oferta_medio) / precio_oficial_medio) * 100, 2) as descuento
	from (select id_prod, avg(precio_oficial) as precio_oficial_medio, avg(precio_oferta) as precio_oferta_medio
		from ventas_agr
		group by id_prod) as nivel_producto)
select * 
from (select id_prod, descuento, cume_dist() over(order by descuento) as dist_acum 
	from tabla_descuento) as acumulados
where dist_acum >= 0.9;





-- SPRINT SEMANA 4 - TAREA 2
---------------------------------------------

-- ¿Cuántos productos diferentes estamos vendiendo?

select count(distinct producto)
from productos; -- estamos vendiendo 144 productos diferentes

-- ¿Con qué productos necesitaríamos quedarnos para mantener el 90% de la facturación actual?
-- Recomendable siempre hacer diseño antes de ponernos con el código sql
-- 1º Diseño de lo que queremos optener funcionalmente, o sea, los pasos que necesitamos dar
-- 2º Miramos en qué tabla o tablas está la información que necesitamos
-- 3º Miramos si la tabla está al nivel de agregación para resolver esa consulta

-- 1º Diseño: 
	-- Pensamos que hace falta el campo producto, el campo facturación, y para hacer acumulados, otro campo con el total de facturación para
	-- tenerlo en %, más otro campo más con la facturación acumulada. Tendremos que ordenar por facturación para sacar los acumulados.
-- 2º Buscamos tabla o tablas para obtener la información y llegamos a la conclusión que la podemos obtener de ventas_agr
-- 3º Miramos el nivel de agregación:

select *
from ventas_agr; -- Necesitamos que esté a nivel de producto, pero el campo id_prod se repiten los valores, por lo que 
				 -- tendremos que agregar la facturación total de cada producto haciendo group by y ordenando en descendente

select id_prod, sum(facturacion) as facturacion_prod
from ventas_agr
group by id_prod
order by facturacion_prod desc; -- Pero también necesitamos la facturación acumulada por lo que:

select id_prod, sum(facturacion_prod) over(order by facturacion_prod desc) as fact_prod_acum
from (select id_prod, sum(facturacion) as facturacion_prod
	 from ventas_agr
	 group by id_prod
	 order by facturacion_prod desc) as tabla_facturacion_prod
; -- Pero necesitamos también otra columna con el total de facturación, por tanto:

select 	id_prod,
		facturacion_prod,
		sum(facturacion_prod) over(order by facturacion_prod desc) as fact_prod_acum,
        sum(facturacion_prod) over() fact_prod_total
from (select id_prod, sum(facturacion) as facturacion_prod
	 from ventas_agr
	 group by id_prod
	 order by facturacion_prod desc) as tabla_facturacion_prod
; 	-- Ahora vamos a calcular el % acumulado diviendo el fact_prod_acum por el fact_prod_total, el problema es que no se pueden usar esos campos dentro
	-- del select porque los acabamos de crear, por lo que necesitaremos una subconsulta o una tabla temporal CTE

select *, (fact_prod_acum / fact_prod_total) as fact_prod_acum_porc
from (select id_prod,
			 facturacion_prod,
			 sum(facturacion_prod) over(order by facturacion_prod desc) as fact_prod_acum,
			 sum(facturacion_prod) over() fact_prod_total
	from (select id_prod, sum(facturacion) as facturacion_prod
		 from ventas_agr
		 group by id_prod
		 order by facturacion_prod desc) as tabla_facturacion_prod) as tabla_temporal
; -- Vamos a redondear la columna fact_prod_acum_porc

select *, round((fact_prod_acum / fact_prod_total),2) as fact_prod_acum_porc
from (select id_prod,
			 facturacion_prod,
			 sum(facturacion_prod) over(order by facturacion_prod desc) as fact_prod_acum,
			 sum(facturacion_prod) over() fact_prod_total
	from (select id_prod, sum(facturacion) as facturacion_prod
		 from ventas_agr
		 group by id_prod
		 order by facturacion_prod desc) as tabla_facturacion_prod) as tabla_temporal
; -- Ahora necesitamos aplicar el criterio de decisión (90%) o sea, meter un where para filtrar por <=90%, pero el where no se puede usar por
  -- el orden de ejecución, por lo que haremos mediante un cte

with tabla_temporal2 as (
	select *, round((fact_prod_acum / fact_prod_total),2) as fact_prod_acum_porc
	from (select id_prod,
				 facturacion_prod,
				 sum(facturacion_prod) over(order by facturacion_prod desc) as fact_prod_acum,
				 sum(facturacion_prod) over() fact_prod_total
		from (select id_prod, sum(facturacion) as facturacion_prod
			 from ventas_agr
			 group by id_prod
			 order by facturacion_prod desc) as tabla_facturacion_prod) as tabla_temporal
             )
select id_prod, fact_prod_acum, fact_prod_acum_porc
from tabla_temporal2
where fact_prod_acum_porc <= 0.9; 	-- Ya hemos resuelto la preunta de negocio. Estmos recogiendo los productos que tenemos que mantener para
									-- mantener el 90% de la facturación actual. O sea, si eliminamos el resto de productos que no están en este output
                                    -- entonces, mantendremos el 90% de la facturación actual al mismo tiempo que reducimos costes.
		

with fact_prod_acum_porc as (
	select *, round((fact_prod_acum / fact_prod_total),2) as fact_prod_acum_porc
	from (select id_prod,
		   sum(facturacion_prod) over (order by facturacion_prod desc) as fact_prod_acum,
		   sum(facturacion_prod) over() as fact_prod_total
			from (select id_prod, sum(facturacion) as facturacion_prod
				  from ventas_agr
				  group by id_prod
				  order by facturacion_prod desc) as tabla_fact_prod) as tabla_temporal
                  )
select id_prod, fact_prod_acum, fact_prod_acum_porc
from fact_prod_acum_porc
where fact_prod_acum_porc <= 0.9
;


-- Y por tanto ¿qué productos concretos podríamos eliminar y seguir manteniendo el 90% de la facturación?
-- 1º Necesitamos identificar el total de productos distintos que estamos vendiendo, eliminando los seleccionados anteriormente
-- 2º Sacaremos un anti left join de la tabla de la pregunta anterior

-- Paso 1: Copiamos el código del output anterior

with tabla_temporal2 as (
	select *, round((fact_prod_acum / fact_prod_total),2) as fact_prod_acum_porc
	from (select id_prod,
				 facturacion_prod,
				 sum(facturacion_prod) over(order by facturacion_prod desc) as fact_prod_acum,
				 sum(facturacion_prod) over() fact_prod_total
		from (select id_prod, sum(facturacion) as facturacion_prod
			 from ventas_agr
			 group by id_prod
			 order by facturacion_prod desc) as tabla_facturacion_prod) as tabla_temporal
             )
select id_prod, fact_prod_acum, fact_prod_acum_porc
from tabla_temporal2
where fact_prod_acum_porc <= 0.9;

-- Paso 2: Encapsulamos todo ese código dentro de otra cte

with productos_a_mantener as (
	with tabla_temporal2 as (
		select *, round((fact_prod_acum / fact_prod_total),2) as fact_prod_acum_porc
		from (select id_prod,
					 facturacion_prod,
					 sum(facturacion_prod) over(order by facturacion_prod desc) as fact_prod_acum,
					 sum(facturacion_prod) over() fact_prod_total
			from (select id_prod, sum(facturacion) as facturacion_prod
				 from ventas_agr
				 group by id_prod
				 order by facturacion_prod desc) as tabla_facturacion_prod) as tabla_temporal
				 )
	select id_prod, fact_prod_acum, fact_prod_acum_porc
	from tabla_temporal2
	where fact_prod_acum_porc <= 0.9
    ) -- luego volveremos a insertar este código para continuar con la consulta, porque ahora necesitamos sacar una consulta con todos los productos:

select id_prod
from ventas_agr; -- Pero están repetidos, necesitamos los productos únicos:

select distinct id_prod
from ventas_agr; -- Ahora vamos a unir las tablas mediante left join, pero poniendo el código de la tabla temporal por delante:

with productos_a_mantener as (
	with tabla_temporal2 as (
		select *, round((fact_prod_acum / fact_prod_total),2) as fact_prod_acum_porc
		from (select id_prod,
					 facturacion_prod,
					 sum(facturacion_prod) over(order by facturacion_prod desc) as fact_prod_acum,
					 sum(facturacion_prod) over() fact_prod_total
			from (select id_prod, sum(facturacion) as facturacion_prod
				 from ventas_agr
				 group by id_prod
				 order by facturacion_prod desc) as tabla_facturacion_prod) as tabla_temporal
				 )
	select id_prod, fact_prod_acum, fact_prod_acum_porc
	from tabla_temporal2
	where fact_prod_acum_porc <= 0.9
    )
select distinct *
from ventas_agr as v
	left join productos_a_mantener as p
    on v.id_prod = p.id_prod; 	-- el output sale con registros nulos porque son productos que no existen en la tabla p, por lo que tenemos que filtrar
								-- haciendo where para sacar solo los productos a eliminar manteniendo el 90% de la facturación y responder así
								-- a la pregunta de negocio

with productos_a_mantener as (
	with tabla_temporal2 as (
		select *, round((fact_prod_acum / fact_prod_total),2) as fact_prod_acum_porc
		from (select id_prod,
					 facturacion_prod,
					 sum(facturacion_prod) over(order by facturacion_prod desc) as fact_prod_acum,
					 sum(facturacion_prod) over() fact_prod_total
			from (select id_prod, sum(facturacion) as facturacion_prod
				 from ventas_agr
				 group by id_prod
				 order by facturacion_prod desc) as tabla_facturacion_prod) as tabla_temporal
				 )
	select id_prod, fact_prod_acum, fact_prod_acum_porc
	from tabla_temporal2
	where fact_prod_acum_porc <= 0.9
    )
select distinct v.id_prod
from ventas_agr as v
	left join productos_a_mantener as p
    on v.id_prod = p.id_prod
where p.id_prod is null; -- podríamos esos 130 productos para mantener el 90% de la facturación




-- SPRINT SEMANA 4 - TAREA 3
---------------------------------------------

-- ¿Qué líneas de producto diferentes estamos vendiendo?

select distinct linea
from productos;


-- ¿Cual es la contribución (en porcentaje) de cada línea al total de facturación?
-- La facturación está en la tabla ventas_agr, pero ahí no tenemos la línea de producto, pero sí el id_prod para luego hacer join
-- 1º Unificar la tabla donde esté la linea con la tabla donde esté la facturación
-- 2º Para saber la contribución de cada linea, agregar por línea para calcular el total de la facturación
-- 3º Para saber cuánto contribuye cada línea al total, agregar el total total y dividir el total de cada línea al total total

-- Paso 1: Unificar

select linea, facturacion
from ventas_agr as v
	left join productos as p
	on v.id_prod = p.id_prod; 

-- Paso 2: Agregar por línea

select linea, sum(facturacion) as fact_linea
from ventas_agr as v
	left join productos as p
	on v.id_prod = p.id_prod
group by linea; 

-- Paso 3: Agregar por totales

with facturacion_por_linea as (
	select linea, sum(facturacion) as fact_linea
	from ventas_agr as v
		left join productos as p
		on v.id_prod = p.id_prod
	group by linea)
select linea, fact_linea, fact_linea / sum(fact_linea) over() as pct_linea
from facturacion_por_linea; -- vamos a redondear el output de pct_linea

with facturacion_por_linea as (
	select linea, sum(facturacion) as fact_linea
	from ventas_agr as v
		left join productos as p
		on v.id_prod = p.id_prod
	group by linea)
select linea, fact_linea, round(fact_linea / sum(fact_linea) over(), 2) as pct_linea
from facturacion_por_linea
order by pct_linea desc;

-- ¿Podríamos prescindir de alguna línea de productos sin que afecte mucho a la facturación?
#Sí, de Outdoor Protection que solo supone el 1% de la facturación


-- Dentro de la línea que más facture ¿hay algún producto concreto que esté en tendencia?
-- Definimos tendencia como el crecimiento de Q2-2018 sobre Q1-2018

-- Segun consulta anterior, la que mas factura es 'Personal Accessories'

-- Para resolver a esta consulta necesitaremos la linea, el producto, la fecha y la facturación, filtrando por las necesidades del caso

select linea, p.id_prod, fecha, facturacion
from ventas_agr as v
	left join productos as p
	on v.id_prod = p.id_prod
where linea = 'Personal Accessories' and fecha between '2018-01-01' and '2018-06-30'; -- Pero necesitamos que la fecha esté en trimestre:

select linea, p.id_prod, quarter(fecha) as trimestre, facturacion
from ventas_agr as v
	left join productos as p
	on v.id_prod = p.id_prod
where linea = 'Personal Accessories' and fecha between '2018-01-01' and '2018-06-30';

-- Para poder ver el crecimiento entre los trimestre, tendríamos que ordenar por producto y después por trimestre
-- Pero ojo que nos hemos olvidado de ver a qué nivel está la tabla, lo necesitamos que esté a nivel producto, pero estos se repiten
-- por lo que tendremos que agrupar por producto y por fecha

select linea, p.id_prod, quarter(fecha) as trimestre, sum(facturacion) as facturacion_prod
from ventas_agr as v
	left join productos as p
	on v.id_prod = p.id_prod
where linea = 'Personal Accessories' and fecha between '2018-01-01' and '2018-06-30'
group by id_prod,3
order by 2,3; -- Esta es la tabla que necesitamos como punto de partida

-- Necesitamos para saber la tendencia, devidir el dato de facturacion_prod en cada trimestre, pero tendremos que crear una columna para cada trimestre
-- con su facturacion_prod usando case when, o de otra forma es hacer un lag, con partition by para que resetee cuando cambie de producto.
-- Lo metemos todo en una CTE

with producto_trimestre as ( 
	select linea, p.id_prod, quarter(fecha) as trimestre, sum(facturacion) as facturacion_prod
	from ventas_agr as v
		left join productos as p
		on v.id_prod = p.id_prod
	where linea = 'Personal Accessories' and fecha between '2018-01-01' and '2018-06-30'
	group by id_prod,3
	order by 2,3)
select 	linea, id_prod, trimestre, facturacion_prod,
		facturacion_prod / lag(facturacion_prod) over(partition by id_prod order by trimestre) as crecimiento
from producto_trimestre; -- Vamos a filtrar para quitarnos los valores nulos y así tendríamos los crecimientos

with producto_trimestre as ( 
	select linea, p.id_prod, quarter(fecha) as trimestre, sum(facturacion) as facturacion_prod
	from ventas_agr as v
		left join productos as p
		on v.id_prod = p.id_prod
	where linea = 'Personal Accessories' and fecha between '2018-01-01' and '2018-06-30'
	group by id_prod,3
	order by 2,3)
select *
from (select linea, id_prod, trimestre, facturacion_prod,
			 facturacion_prod / lag(facturacion_prod) over(partition by id_prod order by trimestre) as crecimiento
	from producto_trimestre) as subconsulta
where crecimiento is not null
; -- vamos a limpiar la consulta seleccionando solo lo necesario

with producto_trimestre as ( 
	select linea, producto, quarter(fecha) as trimestre, sum(facturacion) as facturacion_prod
	from ventas_agr as v
		left join productos as p
		on v.id_prod = p.id_prod
	where linea = 'Personal Accessories' and fecha between '2018-01-01' and '2018-06-30'
	group by producto,3
	order by 2,3)
select producto, crecimiento
from (select linea, producto, trimestre, facturacion_prod,
			 facturacion_prod / lag(facturacion_prod) over(partition by producto order by trimestre) as crecimiento
	from producto_trimestre) as subconsulta
where crecimiento is not null
order by crecimiento desc; -- por tanto el 'Glacier Basic' es el producto que está en tendencia en el último trimestre


-- SPRINT SEMANA 5 - TAREA 1
---------------------------------------------

-- Segmentación de clientes: 
	-- Crea una matriz de 4 segmentos en base al número de pedidos y la facturación de cada cliente (tienda)
	-- Cada eje dividirá entre los que están por encima y por debajo de la media
	-- Guarda la consulta como una vista para ejecutarla frecuentemente

-- Paso 1: Buscamos dónde tenemos la información que nos piden (pedidos, facturación, tienda), y vemos que esta información está en la vista
-- que nos creamos en ejercicios anteriores nombrada como v_ventas_agr_pedido

-- Paso 2: Tendría que estar a nivel de cliente (tienda), por lo que ejecutamos la consulta y vemos que se repiden los id_tienda, por lo que 
-- no está a nivel de tienda, por lo que tendremos que ponerla a nivel de tienda agregando las variables que nos interesan (pedidos mediante conteo, 
-- y facturación mediante suma)

select *
from v_ventas_agr_pedido;

-- Lo ponemos a nivel de tienda:

select id_tienda, count(id_pedido) as num_pedidos, sum(facturacion) as facturacion_tienda
from v_ventas_agr_pedido
group by id_tienda; 

-- Paso 3: Ahora necesitamos calcular la media de cada variable creada (num_pedidos y facturacion_tienda), y esto lo hacemos con una CTE
-- con dos cálculos dentro de la misma CTE

with pedidos_fact_tienda as (
	select id_tienda, count(id_pedido) as num_pedidos, sum(facturacion) as facturacion_tienda
	from v_ventas_agr_pedido
	group by id_tienda),
    
    medias as (
    select 	avg(num_pedidos) as media_pedidos,
			avg(facturacion_tienda) as media_fact_tienda
            from pedidos_fact_tienda
	)
select *
from medias;

-- Paso 4: Una vez que tenemos la tabla a nivel de tienda y que tenemos calculado las medias de cada variable, necesitamos crear una nueva variable
-- que tomara (variable segmentación) que tomara el valor que yo diga en base al valor de estos 2 ejes, y esto se hace con CASE WHEN
-- Necesitaremos la información de pedidos_fact_tienda y de medias

with pedidos_fact_tienda as (
	select id_tienda, count(id_pedido) as num_pedidos, sum(facturacion) as facturacion_tienda
	from v_ventas_agr_pedido
	group by id_tienda),
    
    medias as (
    select 	avg(num_pedidos) as media_pedidos,
			avg(facturacion_tienda) as media_fact_tienda
            from pedidos_fact_tienda
	)
select *, 
	case 
		when num_pedidos <= media_pedidos and facturacion_tienda <= media_fact_tienda then 'P- F-'
        when num_pedidos <= media_pedidos and facturacion_tienda > media_fact_tienda then 'P- F+'
        when num_pedidos > media_pedidos and facturacion_tienda <= media_fact_tienda then 'P+ F-'
        when num_pedidos > media_pedidos and facturacion_tienda > media_fact_tienda then 'P+ F+'
        else 'ERROR'
	end  as segmentacion
from pedidos_fact_tienda, medias
;

-- Paso 5: Guardarlo como una vista para ejecutarlo más veces

create view v_matriz_segmentacion as 
with pedidos_fact_tienda as (
	select id_tienda, count(id_pedido) as num_pedidos, sum(facturacion) as facturacion_tienda
	from v_ventas_agr_pedido
	group by id_tienda),
    
    medias as (
    select 	avg(num_pedidos) as media_pedidos,
			avg(facturacion_tienda) as media_fact_tienda
            from pedidos_fact_tienda
	)
select *, 
	case 
		when num_pedidos <= media_pedidos and facturacion_tienda <= media_fact_tienda then 'P- F-'
        when num_pedidos <= media_pedidos and facturacion_tienda > media_fact_tienda then 'P- F+'
        when num_pedidos > media_pedidos and facturacion_tienda <= media_fact_tienda then 'P+ F-'
        when num_pedidos > media_pedidos and facturacion_tienda > media_fact_tienda then 'P+ F+'
        else 'ERROR'
	end  as segmentacion
from pedidos_fact_tienda, medias
;



-- Calcula cuantos clientes tenemos en cada segmento de la matriz

select segmentacion, count(id_tienda) as num_clientes
from v_matriz_segmentacion
group by segmentacion;



-- Potencial de desarrollo:
	-- Segmenta las tiendas por su tipo, y calcula el P75 de la facturación
	-- Para cada tienda que esté por debajo del P75 calcula su potencial de desarrollo (diferencia entre la facturación P75 y su facturación)

-- Paso 1: Localizar las tablas necesarias para el ejercicio según los campos que se piden, preparar la tabla al nivel requerido, 
-- y que esté agrupada por tipo.
	-- Necesitamos principalmente el campo facturación que está en la tabla ventas_agr, y el campo tipo que está en la tabla tiendas
    -- A qué nivel está la tabla ventas_agr:

select *
from ventas_agr; 	-- vemos que no está a nivel de tienda porque hay valores repetidos, por lo que hay que agrupar por tienda, agredando la facturacion
					-- mediante función de suma, por tanto:

select id_tienda, sum(facturacion) as facturacion
from ventas_agr
group by id_tienda; 	-- ahora hay que incorporarle la variable tipo de la tabla tiendas, por tanto:

select t.id_tienda, t.tipo, facturacion 
from tiendas as t
	inner join
		(select id_tienda, sum(facturacion) as facturacion
		from ventas_agr
		group by id_tienda) as v
	on t.id_tienda = v.id_tienda
; -- también se puede hacer así según mi criterio, obteniendo mismo resultado:


select v.id_tienda, tipo, sum(facturacion) as facturacion
from ventas_agr as v
	inner join tiendas as t
    on v.id_tienda = t.id_tienda
group by id_tienda; -- pero 

-- Paso 2: Vamos a usar el método del curso (la consulta anterior), para seguirlo todo igual y metemos esa consulta en una cte 
-- y calculamos el percentil

with nivel_tienda as (select t.id_tienda, t.tipo, facturacion 
from tiendas as t
	inner join
		(select id_tienda, sum(facturacion) as facturacion
		from ventas_agr
		group by id_tienda) as v
	on t.id_tienda = v.id_tienda
    )
select *, round(percent_rank() over(partition by tipo order by facturacion) *100,2) as percentil
from nivel_tienda
; -- Vamos a pasar a una tabla más resumida con los ideales de cada segmento, usando where con subconsulta (por el orden de ejecucion)

with nivel_tienda as (select t.id_tienda, t.tipo, facturacion 
from tiendas as t
	inner join
		(select id_tienda, sum(facturacion) as facturacion
		from ventas_agr
		group by id_tienda) as v
	on t.id_tienda = v.id_tienda
    )
select *
from 	(select *, round(percent_rank() over(partition by tipo order by facturacion) *100,2) as percentil
		from nivel_tienda) as con_percentil
where percentil >= 75
; 	-- ahora hay que hacer otro filtro más para quedarnos con el primer registro de cada grupo, creando columna nueva llamada ranking que se segmente
	-- cuando cambiemos de tipo en la tabla, y luego hacer un where para que se quede con ranking=1

with nivel_tienda as (select t.id_tienda, t.tipo, facturacion 
from tiendas as t
	inner join
		(select id_tienda, sum(facturacion) as facturacion
		from ventas_agr
		group by id_tienda) as v
	on t.id_tienda = v.id_tienda
    )
select *, row_number() over(partition by tipo order by percentil) as ranking
from 	(select *, round(percent_rank() over(partition by tipo order by facturacion) *100,2) as percentil
		from nivel_tienda) as con_percentil
where percentil >= 75
; -- ya tenemos el ranking, ahora haremos el filtro por ranking=1

with nivel_tienda as (select t.id_tienda, t.tipo, facturacion 
from tiendas as t
	inner join
		(select id_tienda, sum(facturacion) as facturacion
		from ventas_agr
		group by id_tienda) as v
	on t.id_tienda = v.id_tienda
    )
select *
from 	(select *, row_number() over(partition by tipo order by percentil) as ranking
		from 	(select *, round(percent_rank() over(partition by tipo order by facturacion) *100,2) as percentil
				from nivel_tienda) as con_percentil
		where percentil >= 75) as ranking_1
where ranking = 1
; 	-- vamos a meter esta nueva consulta dentro de otro cte, pero que esté dentro del cte anterior 
	-- (notese que pongo una coma cuando finalizo y empiezo una variable dentro del with)

with nivel_tienda as (select t.id_tienda, t.tipo, facturacion 
from tiendas as t
	inner join
		(select id_tienda, sum(facturacion) as facturacion
		from ventas_agr
		group by id_tienda) as v
	on t.id_tienda = v.id_tienda
    ),
	p75_ideales as (  
	select tipo, facturacion as ideal
	from 	(select *, row_number() over(partition by tipo order by percentil) as ranking
			from 	(select *, round(percent_rank() over(partition by tipo order by facturacion) *100,2) as percentil
					from nivel_tienda) as con_percentil
			where percentil >= 75) as ranking_1
	where ranking = 1
    )
; -- ahora lo que hay que hacer es, dentro de la tabla nivel_tienda, incluir una columna con el valor ideal de la tabla p75_idealesselect mediante join

with nivel_tienda as (select t.id_tienda, t.tipo, facturacion 
from tiendas as t
	inner join
		(select id_tienda, sum(facturacion) as facturacion
		from ventas_agr
		group by id_tienda) as v
	on t.id_tienda = v.id_tienda
    ),
	p75_ideales as (  
	select tipo, facturacion as ideal
	from 	(select *, row_number() over(partition by tipo order by percentil) as ranking
			from 	(select *, round(percent_rank() over(partition by tipo order by facturacion) *100,2) as percentil
					from nivel_tienda) as con_percentil
			where percentil >= 75) as ranking_1
	where ranking = 1
    )
select id_tienda, t.tipo, facturacion, ideal
from nivel_tienda as t
	inner join p75_ideales as i
    on t.tipo = i.tipo; -- ahora viene el paso 3

-- Paso 3: Calcular una variable que sea la diferencia entre el objetivo ideal y la facturación actual para obtener el potencial de desarrollo, metiendo
-- en la consulta alguna lógica para los que estén por encima del p75 que ponga 0 ... mediante case when

with nivel_tienda as (select t.id_tienda, t.tipo, facturacion 
from tiendas as t
	inner join
		(select id_tienda, sum(facturacion) as facturacion
		from ventas_agr
		group by id_tienda) as v
	on t.id_tienda = v.id_tienda
    ),
	p75_ideales as (  
	select tipo, facturacion as ideal
	from 	(select *, row_number() over(partition by tipo order by percentil) as ranking
			from 	(select *, round(percent_rank() over(partition by tipo order by facturacion) *100,2) as percentil
					from nivel_tienda) as con_percentil
			where percentil >= 75) as ranking_1
	where ranking = 1
    )
select 	id_tienda, t.tipo, facturacion, ideal,
		case
			when (ideal - facturacion) <= 0 then 0
            when (ideal - facturacion) > 0 then (ideal - facturacion)
            else -9999999999999999999999999
            end as potencial
from nivel_tienda as t
	inner join p75_ideales as i
    on t.tipo = i.tipo
order by potencial desc; -- parece que el tipo golf shop son los que más margen de mejora tienen
     

-- Reactivación de clientes
	-- Identifica clientes que lleven más de 3 meses sin comprar (versus la última fecha disponible)
	-- Pista: puedes usar la función datediff()

-- Paso 1: Localizar la fecha máxima porque será el punto de partida para tirar hacia atrás

	-- La fecha la vamos a obtener de la tabla ventas_agr
    -- Comprobamos que no está a nivel de tienda porque en la consulta siguiente se repiten los registros del campo id_tienda
    
select *
from ventas_agr;

	-- por lo que en algún momento de la consulta tendremos que agrupar para tener id_tienda con registros únicos
    -- Vamos a localizar la fecha máxima

select max(fecha) as ult_fecha_total
from ventas_agr; 	-- 20/07/2018, en la realidad habría que hacerlo con current_date() 
					-- Guardamos este dato con una cte:

with ultima_fecha_total as (
	select max(fecha) as ult_fecha_total
	from ventas_agr
)

-- Paso 2: Calcular la última fecha de cada cliente

select id_tienda, max(fecha) as ult_fecha_tienda
from ventas_agr
group by id_tienda; -- incluimos esto dentro de la cte anterior:

with ultima_fecha_total as (
		select max(fecha) as ult_fecha_total
		from ventas_agr),
	ultima_fecha_tienda as (
		select id_tienda, max(fecha) as ult_fecha_tienda
		from ventas_agr
		group by id_tienda)

-- Paso 3: Calcular los días que lleva sin comprar (comparando los dos anteriores)

with ultima_fecha_total as (
		select max(fecha) as ult_fecha_total
		from ventas_agr),
	ultima_fecha_tienda as (
		select id_tienda, max(fecha) as ult_fecha_tienda
		from ventas_agr
		group by id_tienda)
select *
from ultima_fecha_tienda, ultima_fecha_total;

-- Paso 4: Filtrarlo por 90 días, de tal forma que si han pasado más de 90 días, diremos que el cliente está inactivo, para lo que necesitamos
-- crear una columna con el resultado de restar las dos columnas anteriores

with ultima_fecha_total as (
		select max(fecha) as ult_fecha_total
		from ventas_agr),
	ultima_fecha_tienda as (
		select id_tienda, max(fecha) as ult_fecha_tienda
		from ventas_agr
		group by id_tienda)
select *, datediff(ult_fecha_total, ult_fecha_tienda) as dias_sin_comprar
from ultima_fecha_tienda, ultima_fecha_total; -- ahora filtramos para saber qué tiendas llevan más de 90 días sin comprar

with ultima_fecha_total as (
		select max(fecha) as ult_fecha_total
		from ventas_agr),
	ultima_fecha_tienda as (
		select id_tienda, max(fecha) as ult_fecha_tienda
		from ventas_agr
		group by id_tienda)
select *	
from    (select *, datediff(ult_fecha_total, ult_fecha_tienda) as dias_sin_comprar
		from ultima_fecha_tienda, ultima_fecha_total) as tabla
where dias_sin_comprar > 90;


# SPRINT SEMANA 6 - TAREA 1
---------------------------------------------

-- Genera un sistema de recomendación item-item
	-- Que localice aquellos productos que son comprados frecuentemente en el mismo pedido
	-- Y recomiende a cada tienda según su propio historial de productos comprados
	-- NOTA: tendrás que cambiar una opción para que no genere timeout:
	-- Edit --> Preferences --> SQL Editor --> DBMS connection read timeout interval (in seconds)
-- Pasos a seguir:
-- Crea una tabla con el maestro de recomendaciones item-item

create table recomendador
select v1.id_prod as antecedente, v2.id_prod as consecuente, count(v1.id_pedido) as frecuencia
from v_ventas_agr_pedido as v1
	inner join v_ventas_agr_pedido as v2
     on v1.id_pedido = v2.id_pedido #cruzamos pedido con pedido para identificar los productos que se compran en el mismo pedido
        and v1.id_prod != v2.id_prod #quitamos los registros de cada producto consigo mismo
        and v1.id_prod < v2.id_prod #evitar matriz simetrica
group by v1.id_prod, v2.id_prod; #en cuantos pedidos aparecen juntos


-- Crea una consulta que genere las recomendaciones para cada cliente concreto
-- Y que sea capaz de eliminar los productos ya comprados por ese cliente concreto

-- Paso 1: Vamos a sacar los productos que ha comprado una tienda cualquiera, por lo que seleccionamos el id_tienda de una de ellas

select *
from ventas_agr; -- por ejemplo usaremos la id_tienda 1201

-- Paso 2: Filtramos con los registros de la tabla ventas_agr de la tienda 1201, para saber los productos que ha comprado la tienda 1201

select id_prod, id_tienda
from ventas_agr
where id_tienda = '1201';

-- Paso 3: Lo vamos a meter en una cte para usarlo más adelante

with imput_cliente as (
	select id_prod, id_tienda
	from ventas_agr
	where id_tienda = '1201')

-- Paso 4: Vamos a saber qué productos recomendar a la tienda seleccionada según la tabla recomendador

with imput_cliente as (
	select id_prod, id_tienda
	from ventas_agr
	where id_tienda = '1201')
select *
from imput_cliente as c
	left join recomendador as r
    on c.id_prod = r.antecedente
    
-- Paso 5: Agrupamos por consecuente y sumamos por frecuencia	

with imput_cliente as (
	select id_prod, id_tienda
	from ventas_agr
	where id_tienda = '1201')
select consecuente, sum(frecuencia) as frecuencia
from imput_cliente as c
	left join recomendador as r
    on c.id_prod = r.antecedente
group by consecuente
order by frecuencia desc;

-- Paso 6: Eliminamos los productos ya comprados por ese cliente concreto. 
	
    -- Primero convertiremos el select anterior en otra cte dentro de la anterior

with imput_cliente as (
		select id_prod, id_tienda
		from ventas_agr
		where id_tienda = '1201')
	productos_recomendados as (
		select consecuente, sum(frecuencia) as frecuencia
		from imput_cliente as c
			left join recomendador as r
			on c.id_prod = r.antecedente
		group by consecuente
		order by frecuencia desc)

	-- Segundo eliminaremos de esta tabla, los productos que ya fueron comprados previamente por esta tienda (en esta caso estamos en el caso más difícil, 
    -- o sea, queremos recomendar siempre cosas nuevas). Tendremos que hacer un antijoin de esta tabla que hemos generado con productos recomendados, 
    -- con la otra tabla de imput_cliente, de tal manera que si hay algún producto de productos recomendados que ya estuviera en el imput_cliente, 
    -- deberíamos eliminarlo de productos recomendados

with imput_cliente as (
		select id_prod, id_tienda
		from ventas_agr
		where id_tienda = '1201'),
	productos_recomendados as (
		select consecuente, sum(frecuencia) as frecuencia
		from imput_cliente as c
			left join recomendador as r
			on c.id_prod = r.antecedente
		group by consecuente
		order by frecuencia desc)
select *
from productos_recomendados as r
	left join imput_cliente as c
    on r.consecuente = c.id_prod
; 	-- aquí sale una tabla con algunos registros en blanco (null) en las columnas id_prod, id_tienda. 
	-- Esto es que son productos que no están en la tabla imput_cliente, y por tanto son con los que me quiero quedar, y los que sí existen, o sea,
    -- los que no están como null, son productos que ya se han comprado y no queremos estos.
    -- Haremos el filtro correspondiente para quedarnos con esos productos y terminar el antijoin.

with imput_cliente as (
		select id_prod, id_tienda
		from ventas_agr
		where id_tienda = '1201'),
	productos_recomendados as (
		select consecuente, sum(frecuencia) as frecuencia
		from imput_cliente as c
			left join recomendador as r
			on c.id_prod = r.antecedente
		group by consecuente
		order by frecuencia desc)
select *
from productos_recomendados as r
	left join imput_cliente as c
    on r.consecuente = c.id_prod
where id_prod is null; 	-- eliminamos las columnas id_prod, id_tienda, que ya no nos sirven y renombramos las otras para que otros equipos de la empresa
						-- puedan comprender el output de la consulta

with imput_cliente as (
		select id_prod, id_tienda
		from ventas_agr
		where id_tienda = '1201'),
	productos_recomendados as (
		select consecuente, sum(frecuencia) as frecuencia
		from imput_cliente as c
			left join recomendador as r
			on c.id_prod = r.antecedente
		group by consecuente
		order by frecuencia desc)
select consecuente as recomendado, frecuencia
from productos_recomendados as r
	left join imput_cliente as c
    on r.consecuente = c.id_prod
where id_prod is null; -- podemos limitarlo con limit a la hora de recomendar por ejemplo por 10 productos

with imput_cliente as (
		select id_prod, id_tienda
		from ventas_agr
		where id_tienda = '1201'),
	productos_recomendados as (
		select consecuente, sum(frecuencia) as frecuencia
		from imput_cliente as c
			left join recomendador as r
			on c.id_prod = r.antecedente
		group by consecuente
		order by frecuencia desc)
select consecuente as recomendado, frecuencia
from productos_recomendados as r
	left join imput_cliente as c
    on r.consecuente = c.id_prod
where id_prod is null
limit 10; -- este es el resultado final, es solo para la tienda 1201, para otra tienda cliente, cambiar el código de tienda
