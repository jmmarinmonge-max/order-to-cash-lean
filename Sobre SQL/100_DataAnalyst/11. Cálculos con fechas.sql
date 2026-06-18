-- CÁLCULOS CON FECHAS

-- 1. Calcular la edad de los empleados ya que tenemos la edad de nacimiento
	-- 1.1 Añadir columna para guardar los datos de la edad
    ALTER TABLE limpieza ADD COLUMN age INT;
    
    -- 1.2 Prueba para ver resultado de calcular la diferencia entre el año de 
    -- nacimiento y la fecha actual
    SELECT name, birth_date, start_date, timestampdiff(year, birth_date, start_date) as edad_de_ingreso FROM limpieza; 
    
    -- 1.3 Actualizar columna age con los datos de la prueba anterior
    UPDATE limpieza SET age = timestampdiff(year, birth_date, CURDATE());