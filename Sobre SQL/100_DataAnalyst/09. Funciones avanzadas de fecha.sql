-- OTRAS FUNCIONES DE FECHA Y HORA. Para la columna finish_date.

-- Convertir el valor en objeto de fecha (timestamp), eliminando los caracteres UTC.
SELECT finish_date, str_to_date(finish_date, '%Y-%m-%d %H:%i:%s') AS fecha FROM limpieza;

-- Convertir de objeto de fecha-hora, a objeto de fecha, y luego que lo convierta en 
-- formato fecha, para sacar la parte de la horas.
SELECT finish_date, date_format(str_to_date(finish_date, '%Y-%m-%d %H:%i:%s'), '%Y-%m-%d') AS fecha FROM limpieza;

-- Separar solo la hora
SELECT finish_date, date_format(finish_date, '%H:%i:%s') AS hour_stamp FROM limpieza;

-- # En caso de que queramos dividir los elementos de la hora
SELECT finish_date,
	date_format(finish_date, '%H') AS horas,
    date_format(finish_date, '%i') AS minutos,
    date_format(finish_date, '%s') AS segundos,
    date_format(finish_date, '%H:%i:%s') AS hour_stamp
FROM limpieza;

/*  Diferencia entre timestamp y datetime
	-- timestamp (YYYY-MM-DD HH:MM:SS----) - desde: 01 enero 1970 a las 00:00:00 UTC, 
    hasta milésimas de segundo
    -- datetime desde año 1000 a 9999 - no tiene en cuenta la zona horaria, hasta segundos */

--PARA PASAR DE FECHA año-mes-dia a año-mes y así calcular las tendencias mensuales de las ventas.
SELECT strftime('%Y-%m', fecha) AS mes, SUM(precio_total) AS ingreso_mensual
FROM tickets
GROUP BY mes
ORDER BY mes;


