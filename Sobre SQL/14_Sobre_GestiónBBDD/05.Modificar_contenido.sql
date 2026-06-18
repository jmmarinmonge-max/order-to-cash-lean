--Insertar un registro con datos para todos los campos
--El orden debe coincidir con el de los campos. Podemos insertar varios registros a la vez.
INSERT INTO nombre_tabla
VALUES (valor1,valor2,valorn),
(valor1,valor2,valorn),
(valor1,valor2,valorn);

--Insertar un registro con datos para solo algunos campos
--Solo es necesario incluir los campos en los que haya que introducir datos
INSERT INTO nombre_tabla (campo1,campo2,campon)
VALUES (valor1,valor2,valorn),
(valor1,valor2,valorn),
(valor1,valor2,valorn);

--Modificar registro-s existentes en una tabla que ya está creada
--Modificar uno o varios registros
--Mucho cuidado con el WHERE, si no se especifica se moficarán todos los registros!
UPDATE nombre_tabla SET campo1 = valor1, campo2 = valor2, campon = valorn
WHERE condicion;

--Eliminar registro-s existentes en una tabla que ya está creada
--Eliminar uno o varios registros
--Mucho cuidado con el WHERE, si no se especifica se borrarán todos los registros!
DELETE FROM nombre_tabla
WHERE condicion;

--COMMIT Y ROLLBACK
--MySql usa por defecto el autocommit, lo cual significa que, salvo que quieras, no te tienes que
--preocupar por estos términos.
--Pero es un concepto importante que debes conocer por si trabajas con otras bases de de datos.
--• Puedes pensar en COMMIT como el botón de guardar de powerpoint
--• Hasta que no lo haces los cambios no se quedan definitivamente guardados
--• Pero una vez que lo haces ya no se puede volver a versiones previas
--• Puedes pensar en ROLLBACK como la flechita de deshacer en powerpoint
--• Al hacerlo se volverá al estado del último COMMIT
--• Pero aunque hagas varios ROLLBACK no vas a poder volver más atrás del último COMMIT
--Si quieres usar este recurso en MySql tienes que desactivar el autocommit.
--Se hace con 
SET autocommit=0;
--Puedes volver a activarlo con 
SET autocommit=1;