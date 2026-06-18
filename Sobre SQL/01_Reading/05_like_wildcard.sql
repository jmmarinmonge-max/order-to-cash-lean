-- Obtiene todos datos de la tabla "users" que contienen un email con el texto "gmail.com" en su parte final
SELECT * FROM users WHERE email LIKE '%gmail.com';

-- Obtiene todos datos de la tabla "users" que contienen un email con el texto "sara" en su parte inicial
SELECT * FROM users WHERE email LIKE 'sara%';

-- Obtiene todos datos de la tabla "users" que contienen un email una arroba
SELECT * FROM users WHERE email LIKE '%@%';

-- Obtiene aquellos registros que cumplan cierta parte del valor que estoy buscando, por ejemplo, si le digo
-- que me devuelva aquellos valores que tengan la palabra madrid dentro del valor, pero necesito que sustituya
-- ciertos caracteres a la hora de mostrar el output, usamos el operador % para cualquier número de caracteres
-- y el operador _ para un solo caracter
SELECT * FROM users WHERE email LIKE 'sara_';