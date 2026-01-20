--Partir del diseño del esquema relacional
2. Poner el esqueleto CREATE TABLE nombre_tabla();
3. Ir incluyendo los campos uno por línea y finalizando con coma:
1. Nombre del campo
2. Tipo del campo
3. Constraints
4. Identificar la clave primaria
5. Identificar las claves foráneas


--Plantilla
CREATE TABLE nombre_tabla (
campo1 INT AUTO_INCREMENT,
campo2 VARCHAR(20) NOT NULL,
campo3 VARCHAR(20) UNIQUE KEY,
campo4 INT DEFAULT 0,
PRIMARY KEY (campo1),
FOREIGN KEY (campo2) REFERENCES otra_tabla (campo2) ON DELETE CASCADE
);

--También podríamos crear directamente una tabla a partir del resultado de una consulta. 
--Simplemente comenzamos con CREATE TABLE nombre_tabla y luego ya la consulta normalmente

CREATE TABLE nombre_nueva_tabla
SELECT *
FROM nombre_tabla
WHERE segmento = ‘S1’;

