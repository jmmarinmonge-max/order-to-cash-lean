--1.CREAR LA BASE DE DATOS
CREATE DATABASE IF NOT EXISTS taller;

--2.ACTIVARLA
USE taller;

--3.CREAR LAS TABLAS, RELACIONES Y CAMPOS
--3.1 TABLA CLIENTE
CREATE TABLE cliente (
	id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    cliente VARCHAR(50) DEFAULT 'desconocido',
    direccion VARCHAR(100) DEFAULT 'desconocido',
    telefono INT NOT NULL
    );

--3.2 TABLA VEHÍCULO
CREATE TABLE vehiculo (
	id_vehiculo INT PRIMARY KEY AUTO_INCREMENT,
    matricula VARCHAR(7) UNIQUE NOT NULL,
    marca VARCHAR(50) DEFAULT 'desconocido',
    modelo VARCHAR(50) DEFAULT 'desconocido'
);

--3.3 TABLA SERVICIO
CREATE TABLE servicio (
	id_servicio INT PRIMARY KEY AUTO_INCREMENT,
    servicio VARCHAR(100) NOT NULL,
    precio_piezas DECIMAL NOT NULL,
    horas_mano_obra INT NOT NULL
);	

--3.4 TABLA REPARACIÓN
CREATE TABLE reparacion (
	id_reparacion INT AUTO_INCREMENT,
    id_cliente INT,
    id_vehiculo INT,
    id_servicio INT,
    importe DECIMAL NOT NULL,
PRIMARY KEY (id_reparacion),
FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE CASCADE,
FOREIGN KEY (id_vehiculo) REFERENCES vehiculo(id_vehiculo) ON DELETE CASCADE,
FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio) ON DELETE CASCADE
);	