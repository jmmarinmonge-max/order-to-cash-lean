-- Creo la base de datos llamada clean
CREATE DATABASE IF NOT EXISTS clean;

-- Una vez cargada la tabla, me dispongo a trabajar con la base de datos clean
USE clean;

-- Visualizo la tabla limpieza
SELECT * FROM limpieza;

-- Desactivar modo seguro de MySql para poder hacer modificaciones en las tablas
SET sql_safe_updates = 0;

    -- Para activarlo basta con hacer
    SET sql_safe_updates = 1;

-- Modifico los nombres de las columnas y sus tipos de datos
ALTER TABLE `clean`.`limpieza` 
CHANGE COLUMN `ï»¿Id?empleado` `id_emp` VARCHAR(20) NOT NULL ,
CHANGE COLUMN `Name` `name` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Apellido` `surname` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `gÃ©nero` `gender` VARCHAR(20) NOT NULL ;

-- ELMINIAR DUPLICADOS EN 4 PASOS
-- 1. Contar duplicados
SELECT COUNT(*) AS cantidad_duplicados
FROM (
SELECT id_emp, COUNT(*) AS cantidad_duplicados
FROM limpieza
GROUP BY id_emp
HAVING COUNT(*) > 1
) AS SBQ1;

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

-- MODIFICAR NOMBRE DE LAS COLUMNAS ASÍ COMO SUS FORMATOS DE TIPO DE DATOS

-- Modificar columna surname como varchar 50 caracteres
ALTER TABLE `clean`.`limpieza` 
CHANGE COLUMN `surname` `surname` VARCHAR(50) NULL DEFAULT NULL;

-- Modificar columna star_date como start_date y de momento lo dejamos como varchar(50)
ALTER TABLE `clean`.`limpieza` 
CHANGE COLUMN `star_date` `start_date` VARCHAR(50) NULL DEFAULT NULL;

-- Ver las propiedades de la tabla (Metadatos)
DESCRIBE limpieza;

-- REMOVER LOS ESPACIOS EXTRA EN 2 PASOS

-- 1. Idenficar
SELECT name FROM limpieza
WHERE LENGTH(name) - LENGTH(TRIM(name)) > 0;

-- 2. Actualizar tabla
    -- 2.1 Ensayo
    SELECT name, TRIM(name) AS name
    FROM limpieza
    WHERE LENGTH(name) - LENGTH(TRIM(name)) > 0;

    -- 2.2 Actualizar
    UPDATE limpieza SET name = TRIM(name)
    WHERE LENGTH(name) - LENGTH(TRIM(name)) > 0;

-- LO MISMO CON LA COLUMNA SURNAME

-- 1. Idenficar
SELECT name FROM limpieza
WHERE LENGTH(surname) - LENGTH(TRIM(surname)) > 0;

-- 2. Actualizar tabla
    -- 2.1 Ensayo
    SELECT surname, TRIM(surname) AS surname
    FROM limpieza
    WHERE LENGTH(surname) - LENGTH(TRIM(surname)) > 0;

    -- 2.2 Actualizar
    UPDATE limpieza SET surname = TRIM(surname)
    WHERE LENGTH(surname) - LENGTH(TRIM(surname)) > 0;

-- REMOVER ESPACIOS ENTRE 2 PALABRAS (en 2 pasos)

-- 0. Vamos a meter espacios en los registros de la columna area para trabajar la tarea de remover espacios entre palabras
UPDATE limpieza SET area = REPLACE(area, ' ', '        ');

-- 1. Identificar
SELECT area FROM limpieza 
WHERE area REGEXP '\\s{2,}';
	-- 1.1 Ensayo para ver cómo quedaría la columna area quitando los espacios extra entre palabras
    SELECT area, TRIM(REGEXP_REPLACE(area, '\\s{2,}',' ')) AS ensayo 
    FROM limpieza;

-- 2. Actualizar tabla
UPDATE limpieza SET area = TRIM(REGEXP_REPLACE(area, '\\s{2,}',' '));

-- BUSCAR Y REEMPLAZAR (en 3 pasos)
-- Los registros en la columna genero están en castellano y hay que ponerlos en ingles para nuestro caso de estudio

-- 1. Ensayar
SELECT gender,
CASE
	WHEN gender = 'hombre' THEN 'male'
    WHEN gender = 'mujer' THEN 'female'
    ELSE 'other'
END AS gender1
FROM limpieza;

-- 2. Actualizar tabla
UPDATE limpieza SET gender = CASE
	WHEN gender = 'hombre' THEN 'male'
    WHEN gender = 'mujer' THEN 'female'
    ELSE 'other'
END;

-- 3. Modificar propiedad (si es necesario)
-- En la columna type vemos registros de tipo booleano, que en nuestro ejemplo hace referencia al tipo de contrato,
-- los registros 0 son trabajadores con contrato hibrido, y los 1 son contratos de tipo remoto.
-- Antes de empezar a hacer los cambios, vamos a ver qué tipo de dato presenta la columna type con la siguiente sentencia:
DESCRIBE limpieza;

-- Vemos que tiene valor 'int' (entero) por lo que así no nos dejaría cambiar por el método anterior UPDATE, 
-- pero sí podríamos hacerlo si cambiamos de tipo entero a texto:
ALTER TABLE limpieza MODIFY COLUMN type TEXT;

-- Comprobamos las propiedades para ver que ya se ha cambiado el tipo de dato a texto en la columna type
DESCRIBE limpieza;

-- Ahora sí podemos hacer el cambio en los registros de la columna type
UPDATE limpieza SET type = CASE
	WHEN type = '0' THEN 'hybrid'
    WHEN type = '1' THEN 'remote'
    ELSE 'other'
END;

-- DAR FORMATO DE NÚMERO A UN TEXTO (en 3 pasos)
-- 1. Ensayo
	-- 1.1  Reemplazar el símbolo dolar por un vacío con REPLACE
	-- 1.2 Reemplazar la coma por un vacío con REPLACE
	-- 1.3 Eliminar los vacíos que puedan quedar con TRIM
	-- 1.4 Convertir el resultado final en un número decimal con una precisión de 2 dígitos con CAST

SELECT salary, 
			CAST(TRIM(REPLACE(REPLACE(salary, '$', ''), ',','')) AS decimal (15, 2)) AS salary1 from limpieza;
            
-- 2. Actualización de la tabla
UPDATE limpieza SET salary = CAST(TRIM(REPLACE(REPLACE(salary, '$', ''), ',','')) AS decimal (15, 2));

-- 3. Modificar formato de texto a número
ALTER TABLE limpieza MODIFY COLUMN salary int null;

-- AJUSTAR FORMATOS DE FECHA
-- 1. Comprobar columna a transformar. Hay formatos en formato dd/mm/yyyy, mm/dd/yyyy, y puede que también en formato 
-- dd-mm-yyyy o en formato mm-dd-yyyy, pero en sql, el formato es yyyy-mm-dd
SELECT birth_date FROM limpieza;
-- 2 Dar formato de texto a fecha con 2 funciones:
		-- 2.1.1 str_to_date() para convertir el valor de una cadena en formato mm/dd/yyyy en un objeto de fecha aceptado por sql.
        -- 2.1.2 date_format() que formatea el objeto de fecha resultante en una cadena con el formato yyyy/mm/dd.
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

-- 1. Hacemos copia de seguridad de la columna finish_date
ALTER TABLE limpieza ADD COLUMN date_bu text;

-- 2. Copiamos los datos de finish_date a la columna de date_bu
UPDATE limpieza SET date_bu = finish_date;

-- 3. Actualizamos la fecha a marca de tiempo. Esto es convertir el valor en objeto de fecha (timestamp), eliminando los caracteres UTC
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
    
-- 5. Actualizar la propiedad de finish_date a datetime o fecha pero como en nuestra columna tenemos también espacios en blanco,
-- al hacer la actualización, sql devolverá error, así que lo que hay que hacer es poner los valores en blanco como nulos
	
    -- 5.1 Poner valores blancos como nulos en la columna finish_date
	UPDATE limpieza SET finish_date = NULL
    WHERE finish_date = '';
    
    -- 5.2 Cambiamos la propiedad de la tabla en la columna finish_date
    ALTER TABLE limpieza MODIFY COLUMN finish_date DATETIME;

-- CÁLCULOS CON FECHAS

-- 1. Calcular la edad de los empleados ya que tenemos la edad de nacimiento
	-- 1.1 Añadir columna para guardar los datos de la edad
    ALTER TABLE limpieza ADD COLUMN age INT;
    
    -- 1.2 Prueba para ver resultado de calcular la diferencia entre el año de nacimiento y la fecha actual
    SELECT name, birth_date, start_date, timestampdiff(year, birth_date, start_date) as edad_de_ingreso FROM limpieza; 
    
    -- 1.3 Actualizar columna age con los datos de la prueba anterior
    UPDATE limpieza SET age = timestampdiff(year, birth_date, CURDATE());

-- FUNCIONES DE TEXTO. Crear una nueva columna a partir de los datos disponibles
-- Por ejemplo, vamos a crear un correo electrónico a partir de las columnas disponibles en la tabla

-- 1. Concatenar elementos de la tabla para formar el correo electrónico en una nueva columna,
-- con la siguiente información: primernombredelempleado_lasdosprimerasletrasdelapellido.primeraletradeltipodecontrato@consulting.com
SELECT concat(substring_index(name, ' ', 1), '_', substring(surname, 1, 2), '.', substring(type, 1, 2), '@consulting.com') AS email FROM limpieza;

-- 2. Creamos columna nueva nombrada como email
ALTER TABLE limpieza ADD COLUMN email VARCHAR(100);

-- 3. Actualizar la tabla introduciendo los datos en la columna email 
UPDATE limpieza SET email = concat(substring_index(name, ' ', 1), '_', substring(surname, 1, 2), '.', substring(type, 1, 2), '@consulting.com');

-- EXPORTANDO TABLA FINAL

-- 1. Seleccionamos las columnas que queremos exportar ya que hay columnas que no nos interesan porque fueron objeto de estudio para los ejemplos
SELECT id_emp, name, surname, age, gender, area, salary, email, finish_date FROM limpieza; 

-- 2. En la columna finish_date vemos que hay fechas futuras y no nos interesa esa información, por lo que vamos a condicionar la selección anterior
SELECT id_emp, name, surname, age, gender, area, salary, email, finish_date 
FROM limpieza
WHERE finish_date <= current_date() OR finish_date IS NULL
ORDER BY area, surname;

-- 3. Contar empleados por area
SELECT area, count(*) AS cantidad_empleados FROM limpieza
GROUP BY area
ORDER BY cantidad_empleados DESC;

-- 4. Exportar los datos para trabajarlos en un programa de visualización de datos como Excel, PowerBI, Tableau, Python etc
-- Se exporta haciendo clic en el disquete de la tabla devuelta en la zona de output
-- Lo hacemos para las 2 tablas: 
	-- Una tabla para el numero de empleados por area, 
    -- y otra tabla con toda la información seleccionada anteriormente