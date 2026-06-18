-- DISTRIBUCIONES

-- percent_rank() devuelve el porcentaje de valores que son inferiores al actual y sin contarse a sí mismo
-- cume_dist() devuelve el porcentaje de valores que son inferiores o iguales al actual y contándose a sí mismo

-- Distribucion por percentil percent_rank
select orderNumber, productCode, quantityOrdered, percent_rank() 
over (order by quantityOrdered) as ranking
from classicmodels.orderdetails;

-- Distribucion por percentil percent_rank y con reseteo
select orderNumber, productCode, quantityOrdered, percent_rank() 
over (partition by productCode order by quantityOrdered) as ranking
from classicmodels.orderdetails;

-- Distribucion acumulada por percentil con cume_dist
select orderNumber, productCode, quantityOrdered, cume_dist() 
over (order by quantityOrdered) as ranking
from classicmodels.orderdetails;

-- Distribucion acumulada por percentil cume_dist y con reseteo 
select orderNumber, productCode, quantityOrdered, cume_dist() 
over (partition by productCode order by quantityOrdered) as ranking
from classicmodels.orderdetails;
