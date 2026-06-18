-- PREPARACIÓN DE LA BASE DE DATOS

-- Crear la base de datos nombrada como 'ventas0'
CREATE DATABASE IF NOT EXISTS ventas0;

-- Una vez cargada la tabla, me dispongo a trabajar con la base de datos 'ventas0'
USE ventas0;

-- Visualizo la tabla ventas0
SELECT * FROM ventas0;

-- Desactivar modo seguro de MySql para poder hacer modificaciones en las tablas
SET sql_safe_updates = 0;

-- Creo procedimiento almacenado para visualizar la tabla ventas0
DELIMITER //
CREATE PROCEDURE pv0()
BEGIN
	SELECT * FROM ventas0;
END//

-- Invoco al procedimiento almacenado 'pv0()'
CALL pv0();

-- LIMPIEZA Y TRANSFORMACIÓN DE DATOS

-- Modificar columna 'ï»¿id_producto' como 'id_producto' y lo dejamos como varchar(20)
ALTER TABLE ventas0 
CHANGE COLUMN `ï»¿id_producto` `id_producto` VARCHAR(20) NULL DEFAULT NULL;

-- Visualizo los nombres de los productos
SELECT DISTINCT nombre_producto FROM ventas0;

-- Normalizo los nombres de los productos
UPDATE ventas0
SET nombre_producto = 'Calcetines (Pack de 3) - Edición limitada'
WHERE nombre_producto = 'Calcetines (Pack de 3) - EdiciÃƒÂ³n Limitada';

UPDATE ventas0
SET nombre_producto = 'Camiseta Algodón Talla M - Edición limitada'
WHERE nombre_producto = 'Camiseta AlgodÃƒÂ³n Talla M - EdiciÃƒÂ³n Limitada';

UPDATE ventas0
SET nombre_producto = 'Camiseta Algodón Talla M Talla S'
WHERE nombre_producto = 'Camiseta AlgodÃƒÂ³n Talla M Talla S';

UPDATE ventas0
SET nombre_producto = 'Cinturón de Cuero'
WHERE nombre_producto = 'CinturÃƒÂ³n de Cuero';

UPDATE ventas0
SET nombre_producto = 'Cinturón de Cuero (Color)'
WHERE nombre_producto = 'CinturÃƒÂ³n de Cuero (Color)';

UPDATE ventas0
SET nombre_producto = 'Cinturón de Cuero - Edición limitada'
WHERE nombre_producto = 'CinturÃƒÂ³n de Cuero - EdiciÃƒÂ³n Limitada';

UPDATE ventas0
SET nombre_producto = 'Cinturón de Cuero Talla S'
WHERE nombre_producto = 'CinturÃƒÂ³n de Cuero Talla S';

UPDATE ventas0
SET nombre_producto = 'Falda Vaquera - Edición limitada'
WHERE nombre_producto = 'Falda Vaquera - EdiciÃƒÂ³n Limitada';

UPDATE ventas0
SET nombre_producto = 'Gorra de Baseball'
WHERE nombre_producto = 'Gorra de BÃƒÂ©isbol';

UPDATE ventas0
SET nombre_producto = 'Gorra de Baseball (Color)'
WHERE nombre_producto = 'Gorra de BÃƒÂ©isbol (Color)';

UPDATE ventas0
SET nombre_producto = 'Gorra de Baseball - Edición limitada'
WHERE nombre_producto = 'Gorra de BÃƒÂ©isbol - EdiciÃƒÂ³n Limitada';

UPDATE ventas0
SET nombre_producto = 'Gorra de Baseball Talla S'
WHERE nombre_producto = 'Gorra de BÃƒÂ©isbol Talla S';

UPDATE ventas0
SET nombre_producto = 'Mochila Deportiva - Edición limitada'
WHERE nombre_producto = 'Mochila Deportiva - EdiciÃƒÂ³n Limitada';

UPDATE ventas0
SET nombre_producto = 'Pantalón Vaquero Talla 32'
WHERE nombre_producto = 'PantalÃƒÂ³n Vaquero Talla 32';

UPDATE ventas0
SET nombre_producto = 'Pantalón Vaquero Talla 32 (Color)'
WHERE nombre_producto = 'PantalÃƒÂ³n Vaquero Talla 32 (Color)'; 

UPDATE ventas0
SET nombre_producto = 'Pantalón Vaquero Talla 32 - Edición limitada'
WHERE nombre_producto = 'PantalÃƒÂ³n Vaquero Talla 32 - EdiciÃƒÂ³n Limitada';

UPDATE ventas0
SET nombre_producto = 'Pantalón Vaquero Talla 32 Talla S'
WHERE nombre_producto = 'PantalÃƒÂ³n Vaquero Talla 32 Talla S';

UPDATE ventas0
SET nombre_producto = 'Sudadera con Capucha - Edición limitada'
WHERE nombre_producto = 'Sudadera con Capucha - EdiciÃƒÂ³n Limitada';

UPDATE ventas0
SET nombre_producto = 'Zapatillas Deportivas - Edición limitada'
WHERE nombre_producto = 'Zapatillas Deportivas - EdiciÃƒÂ³n Limitada';

UPDATE ventas0
SET nombre_producto = 'Camiseta Algodón Talla M'
WHERE nombre_producto = 'Camiseta AlgodÃƒÂ³n Talla M';

-- Visualizo la columna ubicacion
SELECT DISTINCT ubicacion FROM ventas0;

-- Normalizo los registros de la columna ubicacion
UPDATE ventas0
SET ubicacion = REPLACE(ubicacion, 'AlmerÃƒÂ­a', 'almería')
UPDATE ventas0
SET ubicacion = REPLACE(ubicacion, 'CADIZ', 'cádiz')
UPDATE ventas0
SET ubicacion = REPLACE(ubicacion, 'CÃƒÂ¡diz', 'cádiz')
UPDATE ventas0
SET ubicacion = REPLACE(ubicacion, 'CÃƒÂ³rdoba', 'córdoba')
UPDATE ventas0
SET ubicacion = REPLACE(ubicacion, 'JaÃƒÂ©n', 'jaén')
UPDATE ventas0
SET ubicacion = REPLACE(ubicacion, 'MÃƒÂ¡laga', 'málaga')
UPDATE ventas0
SET ubicacion = REPLACE(ubicacion, 'SEVILLA', 'sevilla');

-- REMOVER LOS ESPACIOS EXTRA

-- 1. Idenficar (no hay espacios extra)
SELECT nombre_producto FROM ventas0
WHERE LENGTH(nombre_producto) - LENGTH(TRIM(nombre_producto)) > 0;

-- LO MISMO CON LA COLUMNA UBICACION

-- 1. Idenficar (no hay espacios extra)
SELECT ubicacion FROM ventas0
WHERE LENGTH(ubicacion) - LENGTH(TRIM(ubicacion)) > 0;

-- REMOVER ESPACIOS ENTRE PALABRAS

-- 1. Identificar (no hay espacios entre palabras)
SELECT nombre_producto FROM ventas0 
WHERE nombre_producto REGEXP '\\s{2,}';

-- Ver metadatos tabla ventas0
DESCRIBE ventas0; -- vamos a cambiar el tipo de datos

ALTER TABLE ventas0 
CHANGE COLUMN nombre_producto nombre_producto VARCHAR(255) NULL DEFAULT NULL;
ALTER TABLE ventas0
CHANGE COLUMN cantidad cantidad INT NULL DEFAULT NULL;
ALTER TABLE ventas0
CHANGE COLUMN precio_unitario precio_unitario DECIMAL(10,2);
ALTER TABLE ventas0
CHANGE COLUMN id_cliente id_cliente VARCHAR(20);
ALTER TABLE ventas0
CHANGE COLUMN ubicacion ubicacion VARCHAR(100);

-- Comprobar metadados tras cambios realizados
DESCRIBE ventas0;

-- AJUSTAR FORMATOS DE FECHA
SELECT fecha_venta FROM ventas0;

-- Aplicar formato de fecha válido para mysql
SELECT fecha_venta, CASE
	WHEN fecha_venta LIKE '%/%' then date_format(STR_TO_DATE(fecha_venta, '%d/%m/%Y'), '%Y-%m-%d')
	ELSE NULL
END AS new_fecha_venta
FROM ventas0;

-- Actualizar tabla
UPDATE ventas0 SET fecha_venta = CASE
	WHEN fecha_venta LIKE '%/%' then date_format(STR_TO_DATE(fecha_venta, '%d/%m/%Y'), '%Y-%m-%d')
	ELSE NULL
END;

-- Modificar la propiedad de la columna ahora que ya sabemos que el formato está correcto
ALTER TABLE ventas0 MODIFY COLUMN fecha_venta date;

-- Convertir celdas en blanco de la columna ubicacion a null
UPDATE ventas0
SET ubicacion = IF(ubicacion = '', NULL, ubicacion)
WHERE ubicacion = '';

-- Eliminar filas donde cualquier columna contiene un valor NULL
DELETE FROM ventas0 
WHERE
    ubicacion IS NULL OR id_cliente IS NULL
    OR precio_unitario IS NULL
    OR cantidad IS NULL
    OR fecha_venta IS NULL
    OR nombre_producto IS NULL
    OR id_producto IS NULL;
 
-- Crear nueva columna nombrada como 'importe_total'
ALTER TABLE ventas0
ADD COLUMN importe_total DECIMAL(10,2);

-- Actualizar tabla con los registros en la columna 'importe_total'
UPDATE ventas0
SET importe_total = precio_unitario * cantidad;

-- ANÁLISIS DE LOS DATOS LIMPIOS 

-- Ventas totales por año
SELECT YEAR(fecha_venta) AS año, COUNT(*) AS total_ventas
FROM ventas0
GROUP BY año
ORDER BY año;

-- Productos más vendidos por año
SELECT YEAR(fecha_venta) AS año, nombre_producto, SUM(cantidad) AS total_vendido
FROM ventas0
GROUP BY año, nombre_producto
ORDER BY año DESC, total_vendido DESC;

-- Ingresos totales por ubicación
SELECT ubicacion, SUM(importe_total) AS ingresos_totales
FROM ventas0
GROUP BY ubicacion
ORDER BY ingresos_totales DESC;

-- Ticket promedio por año
SELECT YEAR(fecha_venta) AS año, AVG(importe_total) AS ticket_promedio
FROM ventas0
GROUP BY año
ORDER BY año;

-- Cliente que más ha gastado (histórico)
SELECT id_cliente, SUM(importe_total) AS gasto_total
FROM ventas0
GROUP BY id_cliente
ORDER BY gasto_total DESC
LIMIT 1;

-- Tendencia de ventas mensuales por año
SELECT YEAR(fecha_venta) AS año, MONTH(fecha_venta) AS mes, COUNT(*) AS total_ventas
FROM ventas0
GROUP BY año, mes
ORDER BY año, mes;