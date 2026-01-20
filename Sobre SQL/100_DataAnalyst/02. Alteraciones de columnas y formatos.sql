-- Modificar nombre de las columnas así como sus formatos de tipos de datos

-- Modificar columna surname como varchar 50 caracteres
ALTER TABLE `clean`.`limpieza` 
CHANGE COLUMN `surname` `surname` VARCHAR(50) NULL DEFAULT NULL;

-- Modificar columna star_date como start_date y de momento lo dejamos como varchar(50)
ALTER TABLE `clean`.`limpieza` 
CHANGE COLUMN `star_date` `start_date` VARCHAR(50) NULL DEFAULT NULL;