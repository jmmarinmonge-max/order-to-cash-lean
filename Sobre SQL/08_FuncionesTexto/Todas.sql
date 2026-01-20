-- Longitud del texto (tienedo en cuenta los espacios)
select length(customerName)
from classicmodels.customers;

-- Concatenar
select concat(contactFirstName,' ',contactLastName)
from classicmodels.customers;

-- Concatenar con un separador (para no tener que repetir el separador cada vez que mencionamos la variable a concatenar)
select concat_ws('-',contactFirstName,contactLastName)
from classicmodels.customers;

-- Convertir a minúsculas
select lower(customerName)
from classicmodels.customers;

-- Convertir a mayúsculas
select upper(customerName)
from classicmodels.customers;

-- Extraer por la izquierda
select left(customerName,3)
from classicmodels.customers;

-- Extraer texto(texto, inicio, num_caracteres)
select substr(customerName, 3, 4)
from classicmodels.customers;

-- Extraer por la derecha
select right(customerName,3)
from classicmodels.customers;

-- Reemplazar(texto, viejo, nuevo)
select replace(customerName, 'Australian','Australiana')
from classicmodels.customers;