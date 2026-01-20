-- RANKINGS

-- Rankings con empates y huecos ascendente
select orderNumber, productCode, quantityOrdered, rank() 
over (order by quantityOrdered) as ranking
from classicmodels.orderdetails;

-- Rankings con empates y huecos descendente
select orderNumber, productCode, quantityOrdered, rank() 
over (order by quantityOrdered desc) as ranking
from classicmodels.orderdetails;

-- Rankings con empates y sin huecos ascendente
select orderNumber, productCode, quantityOrdered, dense_rank() 
over (order by quantityOrdered) as ranking
from classicmodels.orderdetails;

-- Rankings con empates y sin huecos descendente
select orderNumber, productCode, quantityOrdered, dense_rank() 
over (order by quantityOrdered desc) as ranking
from classicmodels.orderdetails;

-- Rankings sin empates ascendente
select orderNumber, productCode, quantityOrdered, row_number() 
over (order by quantityOrdered) as ranking
from classicmodels.orderdetails;

-- Rankings sin empates descendente
select orderNumber, productCode, quantityOrdered, row_number() 
over (order by quantityOrdered desc) as ranking
from classicmodels.orderdetails;

-- Rakings con empates con reseteo por otra variable
select orderNumber, productCode, quantityOrdered, rank() 
over (partition by productCode order by quantityOrdered) as ranking
from classicmodels.orderdetails;

-- Rakings sin empates con reseteo por otra variable
select orderNumber, productCode, quantityOrdered, row_number() 
over (partition by productCode order by quantityOrdered) as ranking
from classicmodels.orderdetails;

-- Ranking por grupos (ej 5 grupos rankeados)
select orderNumber, productCode, quantityOrdered, ntile(5) 
over (partition by productCode order by quantityOrdered) as ranking_grupo
from classicmodels.orderdetails;