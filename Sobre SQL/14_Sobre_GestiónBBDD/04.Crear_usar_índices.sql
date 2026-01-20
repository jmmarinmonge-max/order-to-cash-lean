--Crear un índice
CREATE INDEX nombre_índice
ON nombre_tabla (nombre_campo);

--Usar un índice. Al hacer una consulta sobre un campo indexado lo aplica automáticamente
SELECT * FROM nombre_tabla WHERE nombre_campo_indexado > 100;

--Mostrar los índices que existen en una tabla
SHOW INDEX FROM nombre_tabla;