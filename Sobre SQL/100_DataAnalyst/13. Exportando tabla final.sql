-- EXPORTANDO TABLA FINAL

-- 1. Seleccionamos las columnas que queremos exportar ya que hay columnas 
-- que no nos interesan porque fueron objeto de estudio para los ejemplos
SELECT id_emp, name, surname, age, gender, area, salary, email, finish_date FROM limpieza; 

-- 2. En la columna finish_date vemos que hay fechas futuras y no nos interesa esa 
-- información, por lo que vamos a condicionar la selección anterior
SELECT id_emp, name, surname, age, gender, area, salary, email, finish_date 
FROM limpieza
WHERE finish_date <= current_date() OR finish_date IS NULL
ORDER BY area, surname;

-- 3. Contar empleados por area
SELECT area, count(*) AS cantidad_empleados FROM limpieza
GROUP BY area
ORDER BY cantidad_empleados DESC;

-- 4. Exportar los datos para trabajarlos en un programa de visualización de datos como Excel, 
-- PowerBI, Tableau, Python etc
-- Se exporta haciendo clic en el disquete de la tabla devuelta en la zona de output
-- Lo hacemos para las 2 tablas: 
	-- Una tabla para el numero de empleados por area, 
    -- y otra tabla con toda la información seleccionada anteriormente