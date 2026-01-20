-- Para eliminar filas donde una columna específica contiene un valor NULL
DELETE FROM tu_tabla WHERE nombre IS NULL;

-- Eliminar filas donde cualquier columna contiene un valor NULL
 DELETE FROM tu_tabla WHERE nombre IS NULL OR apellido IS NULL OR email IS NULL;

 -- Filtrar datos sin eliminar los valores NULL
 SELECT * FROM tu_tabla WHERE nombre IS NOT NULL;

 -- Reemplazar valores NULL por un valor predeterminado, lo que facilita el filtrado
SELECT * FROM tu_tabla WHERE IFNULL(nombre, 'default') != 'default';  -- Reemplaza NULL por 'default' y filtra.
SELECT * FROM tu_tabla WHERE COALESCE(nombre, 'default') != 'default'; -- Alternativa a IFNULL.

-- Reemplazar los valores NULL en una columna con un valor predeterminado en lugar de eliminarlos
UPDATE tu_tabla SET nombre = IFNULL(nombre, 'valor_defecto') WHERE nombre IS NULL;








