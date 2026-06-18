-- Valor absoluto: Devuelve los valores positivos de la columna límite de crédito
select abs(creditLimit)
from classicmodels.customers;

-- Redondear a enteros por abajo
select floor(creditLimit)
from classicmodels.customers;

-- Redondear a enteros por arriba
select ceil(creditLimit)
from classicmodels.customers;

-- Redondear a un número de decimales
select round(creditLimit,2)
from classicmodels.customers;

-- Truncar a un número de decimales
select truncate(creditLimit,1)
from classicmodels.customers;

-- Potencia
select pow(creditLimit,2)
from classicmodels.customers;

-- Raiz cuadrada
select sqrt(creditLimit)
from classicmodels.customers;

-- Aleatorio entre 0 y 1
select rand()
from classicmodels.customers;

-- Aleatorio entre 1 y 10
select rand()*(10-1)+1
from classicmodels.customers;

-- Aleatorio entre 1 y 10 redondeados por abajo
select floor(rand()*(10-1+1)+1)
from classicmodels.customers;