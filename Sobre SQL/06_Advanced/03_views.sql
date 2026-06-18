/*
VIEWS
*/

-- Se trata de una representación virtual de una o más tablas.
-- Pasa lo mismo que con los index, que hace que se haga más rápido las consultas, pero las escrituras, es decir,
-- las actualizaciones, son más lentas.

-- Crea unaa vista llamada "v_adult_users" con los nombres y edades de usuarios de la table "users"
-- que tienen una edad igual o mayor a 18 años.
CREATE VIEW v_adult_users AS
SELECT name, age
FROM users
WHERE age >= 18;

SELECT * FROM v_adult_users;

-- Elimina la vista llamada "v_adult_users"
DROP VIEW v_adult_users;