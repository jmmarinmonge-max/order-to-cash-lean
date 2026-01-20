--Renombrar una tabla
ALTER TABLE nombre_viejo RENAME TO nombre_nuevo;

--Renombrar un campo
ALTER TABLE nombre_tabla RENAME COLUMN nombre_viejo TO nombre_nuevo;

--Añadir un campo
ALTER TABLE nombre_tabla ADD nombre_campo tipo_dato;

--Eliminar un campo
ALTER TABLE nombre_tabla DROP COLUMN nombre_campo;

--Añadir un constraint
--Hay que “redefinir” el campo con el tipo y CON los constraints que queramos
ALTER TABLE nombre_tabla ADD nombre_constraint nombre_campo;

--Eliminar un constraint
ALTER TABLE nombre_tabla DROP nombre_constraint nombre_campo;

--Modificar un constraint
--Hay que “redefinir” el campo con el tipo y CON los constraints que queramos
ALTER TABLE nombre_tabla MODIFY nombre_campo tipo_dato nombre_constraint;