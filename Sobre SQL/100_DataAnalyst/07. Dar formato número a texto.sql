-- DAR FORMATO DE NÚMERO A UN TEXTO (en 3 pasos)
-- 1. Ensayo
	-- 1.1  Reemplazar el símbolo dolar por un vacío con REPLACE
	-- 1.2 Reemplazar la coma por un vacío con REPLACE
	-- 1.3 Eliminar los vacíos que puedan quedar con TRIM
	-- 1.4 Convertir el resultado final en un número decimal con una precisión de 2 dígitos con la CAST

SELECT salary, 
			CAST(TRIM(REPLACE(REPLACE(salary, '$', ''), ',','')) AS decimal (15, 2)) AS salary1 from limpieza;
            
-- 2. Actualización de la tabla
UPDATE limpieza SET salary = CAST(TRIM(REPLACE(REPLACE(salary, '$', ''), ',','')) AS decimal (15, 2));

-- 3. Modificar formato de texto a número
ALTER TABLE limpieza MODIFY COLUMN salary int null;