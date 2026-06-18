use classicmodels;

--Extrae los modelos de producto (productName) cuyo stock (quantityInStock) sea inferior al de la media de su línea de producto (productLine). Usa la tabla products
with stock_medio_por_linea as(
	select productLine, avg(quantityInStock) as stock_medio_linea
    from products
    group by productLine)
select productName, quantityInStock, stock_medio_linea
from products as p
	inner join stock_medio_por_linea as s
	on p.productLine = s.productLine
where p.quantityInStock < s.stock_medio_linea;

--Saca una tabla que contenga para cada cliente: nombre (customers), teléfono (customers), total de pedidos realizados (orders) y fecha del último pago (payments)
with datos_customers as (select customerNumber, customerName, phone from customers),
	 datos_orders as (select customerNumber, count(customerNumber) as total_pedidos from orders group by customerNumber),
     datos_payments as (select customerNumber, max(paymentDate) as fecha_ult_pago from payments group by customerNumber)
select customerName, phone, total_pedidos, fecha_ult_pago
from datos_customers as c
	inner join datos_orders as d 
    on c.customerNumber = d.customerNumber
    inner join datos_payments as p 
    on c.customerNumber = p.customerNumber