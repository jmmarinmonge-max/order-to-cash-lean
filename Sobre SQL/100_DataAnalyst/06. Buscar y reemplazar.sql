-- BUSCAR Y REEMPLAZAR (en 3 pasos)
-- Los registros en la columna genero están en castellano y hay que ponerlos en 
-- ingles para nuestro caso de estudio

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
-- En la columna type vemos registros de tipo booleano, que en nuestro ejemplo 
-- hace referencia al tipo de contrato,
-- los registros 0 son trabajadores con contrato hibrido, y los 1 son contratos de tipo remoto.
-- Antes de empezar a hacer los cambios, vamos a ver qué tipo de dato presenta la 
-- columna type con la siguiente sentencia:
DESCRIBE limpieza;

-- Vemos que tiene valor 'int' (entero) por lo que así no nos dejaría cambiar por el 
-- método anterior UPDATE, pero sí podríamos
-- hacerlo si cambiamos de tipo entero a texto:
ALTER TABLE limpieza MODIFY COLUMN type TEXT;

-- Comprobamos las propiedades para ver que ya se ha cambiado el tipo de dato a texto en la columna type
DESCRIBE limpieza;

-- Ahora sí podemos hacer el cambio en los registros de la columna type
UPDATE limpieza SET type = CASE
	WHEN type = '0' THEN 'hybrid'
    WHEN type = '1' THEN 'remote'
    ELSE 'other'
END;