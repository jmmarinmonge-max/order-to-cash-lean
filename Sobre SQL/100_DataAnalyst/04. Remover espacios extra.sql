-- REMOVER LOS ESPACIOS EXTRA EN 2 PASOS

-- 1. Idenficar
SELECT name FROM limpieza
WHERE LENGTH(name) - LENGTH(TRIM(name)) > 0;

-- 2. Actualizar tabla
    -- 2.1 Ensayo
    SELECT name, TRIM(name) AS name
    FROM limpieza
    WHERE LENGTH(name) - LENGTH(TRIM(name)) > 0;

    -- 2.2 Actualizar
    UPDATE limpieza SET name = TRIM(name)
    WHERE LENGTH(name) - LENGTH(TRIM(name)) > 0;

-- LO MISMO CON LA COLUMNA SURNAME

-- 1. Idenficar
SELECT name FROM limpieza
WHERE LENGTH(surname) - LENGTH(TRIM(surname)) > 0;

-- 2. Actualizar tabla
    -- 2.1 Ensayo
    SELECT surname, TRIM(surname) AS surname
    FROM limpieza
    WHERE LENGTH(surname) - LENGTH(TRIM(surname)) > 0;

    -- 2.2 Actualizar
    UPDATE limpieza SET surname = TRIM(surname)
    WHERE LENGTH(surname) - LENGTH(TRIM(surname)) > 0;

