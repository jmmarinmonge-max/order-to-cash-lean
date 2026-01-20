-- Case When (para discretizar grupos o para establecer reglas de negocio)
select 
	case
		when creditLimit <= 100000 then '01_Bajo'
		when creditLimit > 100000 then '02_Alto'
		else '99_ERROR'
    end as segmentoLimite
from classicmodels.customers;