-- Reemplazar nulos por valor
select addressLine2, coalesce(addressLine2,'Desconocido')
from classicmodels.customers;

-- Reemplazar nulos por otra variable (en este caso, si la dirección es nulo, pondría el código postal, y si este
-- también fuera nulo, pnodría el Estado, y así sucesivamente)
select addressLine2, state, postalCode,coalesce(addressLine2,postalCode,state)
from classicmodels.customers;