/* Para verificar si hay valores duplicados se usa GROUP BY + HAVING.
GROUP BY nos agrupa los registros por la columna de estudio (la que tenga el valor único o primary key).
HAVING nos especifica una condición que se aplicará después de hacer ese agrupamiento, es decir, 
que solo se seleccionen los conjuntos mayor a 1.*/

SELECT id_emp, COUNT(*) AS cantidad_dulicados
FROM limpieza
GROUP BY id_emp
HAVING COUNT(*) > 1;

-- Pero esta opción nos puede devolver un output con muchas filas y no es lo más óptimo

-- La opción más recomendable sería contar los duplicados directamente

-- 1. Contar registros que devuelva la subconsulta anterior. Output: Devuelve 9 duplicados
SELECT COUNT(*) AS cantidad_duplicados
FROM (
SELECT id_emp, COUNT(*) AS cantidad_duplicados
FROM limpieza
GROUP BY id_emp
HAVING COUNT(*) > 1
) AS SBQ1;

-- Ahora que sabemos que hay 9 valores duplicados, los demás pasos son:

-- 2. Renombrar tabla
RENAME TABLE limpieza TO conduplicados;

-- 3. Crear tabla temporal sin datos duplicados
CREATE TEMPORARY TABLE temp_limpieza AS 
SELECT DISTINCT * FROM conduplicados;

    -- 3.1 Verificar registros de la tabla. Devuelve output 22223
    SELECT COUNT(*) FROM conduplicados; 

    -- 3.2 Verificar registros de la tabla que no tiene duplicados. Devuelve output 22214
    SELECT COUNT(*) FROM temp_limpieza;

-- 4. Convertir la tabla temporal en permanente
CREATE TABLE limpieza AS 
SELECT * FROM temp_limpieza;



