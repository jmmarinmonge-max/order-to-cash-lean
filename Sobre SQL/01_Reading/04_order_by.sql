-- Ordena todos los datos de la tabla "users" por edad (ascendente por defecto)
SELECT * FROM users ORDER BY age;

-- Ordena todos los datos de la tabla "users" por edad de manera ascendente
SELECT * FROM users ORDER BY age ASC;

-- Ordena todos los datos de la tabla "users" por edad de manera descendente
SELECT * FROM users ORDER BY age DESC;

-- Obtiene todos los datos de la tabla "users" con email igual a sara@gmail.com y los ordena por edad de manera descendente
SELECT * FROM users WHERE email='sara@gmail.com' ORDER BY age DESC;

-- Obtiene todos los nombres de la tabla "users" con email igual a sara@gmail.com y los ordena por edad de manera descendente
SELECT name FROM users WHERE email='sara@gmail.com' ORDER BY age DESC;

-- Obtiene el nombre de cliente, país y límite de crédito, ordenados por país descendente y y por límite de crédito, también
-- descendente, pero ahorrándonos de repetir las variables en en el ORDER BY, solo con mencionar la posición
-- que ocupa la variable en el SELECT
SELECT CUSTOMERNAME, country, creditLimit FROM classicmodels.customers
ORDER BY 2 desc, 3 DESC;

-- En situaciones de negocio nos podemos encontar por ejemplo con tener que obtener los 5 clientes con mayor límite de crédito,
-- y esto se consigue combinando ORDER BY con LIMIT
SELECT CUSTOMERNAME, creditLimit FROM classicmodels.customers
ORDER BY creditLimit desc 
LIMIT 5;
