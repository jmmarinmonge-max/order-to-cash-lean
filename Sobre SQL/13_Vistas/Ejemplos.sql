--LECCIONES DE VIEWS
use classicmodels;

--Ej hacer una consulta para extraer
--customerName, orderDate, orderNumber e importe_total de clientes que han comprado más de 20.000 euros en los últimos 5 días
with ultimos_5_dias as (select distinct orderDate 
						from classicmodels.orders
						order by orderDate desc
                        limit 5),
	 importe_total_por_compra as (select orderNumber, sum(quantityOrdered * priceEach) as importe_total
								 from classicmodels.orderdetails
								 group by orderNumber)
select customerName, ord.orderDate, ord.orderNumber, importe_total
from ultimos_5_dias as ult 
	left join classicmodels.orders as ord on ult.orderDate = ord.orderDate
	left join importe_total_por_compra as itc on ord.orderNumber = itc.orderNumber
	left join classicmodels.customers as cus on ord.customerNumber = cus.customerNumber
where importe_total > 20000;

--Pasar la consulta anterior a una vista para ejecutarla frecuentemente
create view clientes_mas_20k_ult_5_dias as 
with ultimos_5_dias as (select distinct orderDate 
						from classicmodels.orders
						order by orderDate desc
                        limit 5),
	 importe_total_por_compra as (select orderNumber, sum(quantityOrdered * priceEach) as importe_total
								 from classicmodels.orderdetails
								 group by orderNumber)
select customerName, ord.orderDate, ord.orderNumber, importe_total
from ultimos_5_dias as ult 
	left join classicmodels.orders as ord on ult.orderDate = ord.orderDate
left join importe_total_por_compra as itc on ord.orderNumber = itc.orderNumber
left join classicmodels.customers as cus on ord.customerNumber = cus.customerNumber
where importe_total > 20000;

--Usar la vista creada
--Podríamos seguir cruzándola, hacer filtros y todo lo mismo que con una tabla normal
--Menos añadir, modificar o eliminar registros, ya que no es una tabla que exista realmente
select * from clientes_mas_20k_ult_5_dias;