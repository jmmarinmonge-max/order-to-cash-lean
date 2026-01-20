-- ANALÍTICAS

-- Lag: significa retardo, y lo que podemos hacer con esta función es acceder al valor de la variable,
-- pero x registros anteriores. Por ejemplo, el dato del día anterior puede ser predictivo para el día siguiente,
-- y lo mismo con respecto a comparar entre el mismo día de años distintos
select postalCode, lag(postalCode) 
over() as ccpp_anterior
from classicmodels.customers;

-- Lag ordenado por la misma (u otra) variable
select postalCode, lag(postalCode) 
over(order by postalCode) ccpp_anterior
from classicmodels.customers;

-- Lag ordenado y reseteado por otra variable
select city, postalCode, lag(postalCode) 
over(partition by city order by city) ccpp_anterior_misma_ciudad
from classicmodels.customers;

-- Lead: es lo mismo pero moviéndote hacia adelante
select postalCode, lead(postalCode) 
over() as ccpp_siguiente
from classicmodels.customers;

-- Lead ordenado por la misma (u otra) variable
select postalCode, lead(postalCode) 
over(order by postalCode) ccpp_siguiente
from classicmodels.customers;

-- Lead ordenado y reseteado por otra variable
select city, postalCode, lead(postalCode) 
over(partition by city order by city) ccpp_siguiente_misma_ciudad
from classicmodels.customers;

-- First_value: el primer valor
select postalCode, first_value(postalCode) 
over() as ccpp_primer_valor
from classicmodels.customers;

-- First_value ordenado y reseteado por otra variable
select city, postalCode, first_value(postalCode) 
over(partition by city order by city) ccpp_primer_valor_misma_ciudad
from classicmodels.customers;

-- Last_value: el último valor
select postalCode, last_value(postalCode) 
over() as ccpp_ult_valor
from classicmodels.customers;

-- Last_value ordenado y reseteado por otra variable
select city, postalCode, last_value(postalCode) 
over(partition by city order by city) ccpp_ult_valor_misma_ciudad
from classicmodels.customers;

-- nth_value ordenado y reseteado por otra variable: el valor n que nosotros quisiéramos
select city, postalCode, nth_value(postalCode,2) 
over(partition by city order by postalCode) ccpp_ult_valor_misma_ciudad
from classicmodels.customers;