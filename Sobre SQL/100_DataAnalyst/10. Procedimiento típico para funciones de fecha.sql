-- 1. Hacemos copia de seguridad de la columna finish_date
ALTER TABLE limpieza ADD COLUMN date_bu text;

-- 2. Copiamos los datos de finish_date a la columna de date_bu
UPDATE limpieza SET date_bu = finish_date;

-- 3. Actualizamos la fecha a marca de tiempo. Esto es convertir el valor en objeto 
-- de fecha (timestamp), eliminando los caracteres UTC
SELECT finish_date, str_to_date(finish_date, '%Y-%m-%d %H:%i:%s') AS fecha FROM limpieza;

	-- 3.1 Actualizamos la tabla
    UPDATE limpieza SET finish_date = str_to_date(finish_date, '%Y-%m-%d %H:%i:%s UTC')
    WHERE finish_date <> '';

-- 4. Separamos la columna finish_date en 2 columnas para la fecha y la hora
	-- 4.1 Creamos las 2 columnas y las dejamos vacías por el momento
	ALTER TABLE limpieza 
		ADD COLUMN fecha date,
		ADD COLUMN hora time;
        
	-- 4.2 Actualizamos los valores de las 2 columnas vacías
    UPDATE limpieza 
		SET fecha = date(finish_date),
			hora = time(finish_date)
	WHERE finish_date IS NOT NULL AND finish_date <> '';
    
-- 5. Actualizar la propiedad de finish_date a datetime o fecha pero como en nuestra 
-- columna tenemos también espacios en blanco, al hacer la actualización, sql devolverá error, 
-- así que lo que hay que hacer es poner los valores en blanco como nulos
	
    -- 5.1 Poner valores blancos como nulos en la columna finish_date
	UPDATE limpieza SET finish_date = NULL
    WHERE finish_date = '';
    
    -- 5.2 Cambiamos la propiedad de la tabla en la columna finish_date
    ALTER TABLE limpieza MODIFY COLUMN finish_date DATETIME;