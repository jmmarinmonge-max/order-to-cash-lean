-- Ventas totales por año
SELECT YEAR(fecha_venta) AS año, COUNT(*) AS total_ventas
FROM ventas0
GROUP BY año
ORDER BY año;

-- Productos más vendidos por año
SELECT YEAR(fecha_venta) AS año, nombre_producto, SUM(cantidad) AS total_vendido
FROM ventas0
GROUP BY año, nombre_producto
ORDER BY año DESC, total_vendido DESC;

-- Ingresos totales por ubicación
SELECT ubicacion, SUM(importe_total) AS ingresos_totales
FROM ventas0
GROUP BY ubicacion
ORDER BY ingresos_totales DESC;

-- Ticket promedio por año
SELECT YEAR(fecha_venta) AS año, AVG(importe_total) AS ticket_promedio
FROM ventas0
GROUP BY año
ORDER BY año;

-- Cliente que más ha gastado (histórico)
SELECT id_cliente, SUM(importe_total) AS gasto_total
FROM ventas0
GROUP BY id_cliente
ORDER BY gasto_total DESC
LIMIT 1;

-- Tendencia de ventas mensuales por año
SELECT YEAR(fecha_venta) AS año, MONTH(fecha_venta) AS mes, COUNT(*) AS total_ventas
FROM ventas0
GROUP BY año, mes
ORDER BY año, mes;

