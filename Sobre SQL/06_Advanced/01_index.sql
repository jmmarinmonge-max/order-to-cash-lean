/*
INDEX
*/

-- El nombre del índice suele ser idx_(+ el nombre del registro asociado)
-- Sirven para dar más rendimiento a la hora de buscar por ejemplo por nombre,
-- es decir, lo hace más rápido, pero pierde rapidez de escritura.

-- Crea un índice llamado "idx_name" en la tabla "users" asociado al campo "name"
CREATE INDEX idx_name ON users(name);

-- Crea un índice único llamado "idx_name" en la tabla "users" asociado al campo "name"
CREATE UNIQUE INDEX idx_name ON users(name);

-- Crea un índice llamado "idx_name_surname" en la tabla "users" asociado a los campos "name" y "surname"
CREATE UNIQUE INDEX idx_name_surname ON users(name, surname);

-- Elimina el índice llamado "idx_name"
DROP INDEX idx_name ON users;