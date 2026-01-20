-- Obtiene las 3 primeras filas de la tabla "users"
SELECT * FROM users LIMIT 3;

-- Obtiene las 2 primeras filas de la tabla "users" con email distinto a sara@gmail.com o edad igual a 15
SELECT * FROM users WHERE NOT email = 'sara@gmail.com' OR age = 15 LIMIT 2;

-- En situaciones de negocio nos podemos encontar por ejemplo con tener que obtener los 5 clientes con mayor límite de crédito,
-- y esto se consigue combinando ORDER BY con LIMIT
SELECT CUSTOMERNAME, creditLimit FROM classicmodels.customers
ORDER BY creditLimit desc 
LIMIT 5;