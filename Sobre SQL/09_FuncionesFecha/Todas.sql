-- Fecha actual
select current_date();

-- Hora actual
select current_time();

-- Fecha y hora actual
select current_timestamp();

-- Extraer fecha
select date(orderDate)
from classicmodels.orders;

-- Extraer día del mes
select day(orderDate)
from classicmodels.orders;

-- Extraer día de la semana
select dayname(orderDate)
from classicmodels.orders;

-- Extraer cualquier elemento(ver: https://www.w3schools.com/mysql/func_mysql_extract.asp)
select extract(month from orderDate)
from classicmodels.orders;

-- Diferencia en días
select datediff(requiredDate,orderDate)
from classicmodels.orders;

-- Diferencia en horas
select timediff(requiredDate,orderDate)
from classicmodels.orders;