-- REMOVER ESPACIOS ENTRE 2 PALABRAS (en 2 pasos)

-- 0. Vamos a meter espacios en los registros de la columna area para trabajar la tarea 
-- de remover espacios entre palabras
UPDATE limpieza SET area = REPLACE(area, ' ', '        ');

-- 1. Identificar
SELECT area FROM limpieza 
WHERE area REGEXP '\\s{2,}';
	-- 1.1 Ensayo para ver cómo quedaría la columna area quitando los espacios extra entre palabras
    SELECT area, TRIM(REGEXP_REPLACE(area, '\\s{2,}',' ')) AS ensayo 
    FROM limpieza;

-- 2. Actualizar tabla
UPDATE limpieza SET area = TRIM(REGEXP_REPLACE(area, '\\s{2,}',' '));