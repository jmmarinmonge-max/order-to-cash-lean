-- AJUSTAR FORMATOS DE FECHA
-- 1. Comprobar columna a transformar. Hay fechas en formato dd/mm/yyyy, mm/dd/yyyy, 
-- y puede que también en formato 
-- dd-mm-yyyy o en formato mm-dd-yyyy, pero en sql, el formato es yyyy-mm-dd
SELECT birth_date FROM limpieza;
-- 2 Dar formato de texto a fecha con 2 funciones:
		-- 2.1.1 str_to_date() para convertir el valor de una cadena en 
        -- formato mm/dd/yyyy en un objeto de fecha aceptado por sql.
        -- 2.1.2 date_format() que formatea el objeto de fecha resultante en una cadena con 
        -- el formato yyyy/mm/dd.
        SELECT birth_date, CASE
			WHEN birth_date LIKE '%/%' then date_format(STR_TO_DATE(birth_date, '%m/%d/%Y'), '%Y-%m-%d')
            WHEN birth_date LIKE '%-%' then date_format(STR_TO_DATE(birth_date, '%m-%d-%Y'), '%Y-%m-%d')
            ELSE NULL
		END AS new_birth_date
        FROM limpieza;
-- 3. Actualizar tabla con el formato cambiado en la columna birth_date
UPDATE limpieza SET birth_date = CASE
	WHEN birth_date LIKE '%/%' then date_format(STR_TO_DATE(birth_date, '%m/%d/%Y'), '%Y-%m-%d')
	WHEN birth_date LIKE '%-%' then date_format(STR_TO_DATE(birth_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

-- 4. Modificar la propiedad de la columna ahora que ya sabemos que el formato está correcto
ALTER TABLE limpieza MODIFY COLUMN birth_date date;

-- Repetir proceso para la columna start_date
SELECT birth_date, CASE
			WHEN start_date LIKE '%/%' then date_format(STR_TO_DATE(start_date, '%m/%d/%Y'), '%Y-%m-%d')
            WHEN start_date LIKE '%-%' then date_format(STR_TO_DATE(start_date, '%m-%d-%Y'), '%Y-%m-%d')
            ELSE NULL
		END AS new_start_date
        FROM limpieza;

UPDATE limpieza SET start_date = CASE
	WHEN start_date LIKE '%/%' then date_format(STR_TO_DATE(start_date, '%m/%d/%Y'), '%Y-%m-%d')
	WHEN start_date LIKE '%-%' then date_format(STR_TO_DATE(start_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE limpieza MODIFY COLUMN start_date date;