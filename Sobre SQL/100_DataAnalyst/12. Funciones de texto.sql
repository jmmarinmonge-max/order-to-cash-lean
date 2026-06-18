-- FUNCIONES DE TEXTO. Crear una nueva columna a partir de los datos disponibles
-- Por ejemplo, vamos a crear un correo electrónico a partir de las columnas disponibles en la tabla

-- 1. Concatenar elementos de la tabla para formar el correo electrónico en una nueva columna,
-- con la siguiente información: primernombredelempleado_lasdosprimerasletrasdelapellido.primeraletradeltipodecontrato@consulting.com
SELECT concat(substring_index(name, ' ', 1), '_', substring(surname, 1, 2), '.', substring(type, 1, 2), '@consulting.com') AS email FROM limpieza;

-- 2. Creamos columna nueva nombrada como email
ALTER TABLE limpieza ADD COLUMN email VARCHAR(100);

-- 3. Actualizar la tabla introduciendo los datos en la columna email 
UPDATE limpieza SET email = concat(substring_index(name, ' ', 1), '_', substring(surname, 1, 2), '.', substring(type, 1, 2), '@consulting.com');
