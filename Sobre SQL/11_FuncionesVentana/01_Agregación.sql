-- Vamos a calcular cuál es la exposición de crédito de cada cliente sobre el total del crédito que tenemos concedido
SELECT customerName, creditLimit, sum(creditLimit) 
OVER() AS RIESGO_TOTAL, creditLimit/sum(creditLimit) OVER() * 100 AS RIESGO
FROM classicmodels.customers;

-- Funcion: conteo, Ventana: total. Vamos a sacar el conteo del total de registros a partir de la venta total de datos
-- renombrado como pedidos totales
select productCode, count(*) 
over() as Pedidos_totales
from classicmodels.orderdetails;

-- Funcion: conteo, Ventana: segmentada. Sacamos el conteo de registros segmentado por código de producto y no por el total
select productCode, count(*) 
over(partition by productCode) as Pedidos_totales_por_prod
from classicmodels.orderdetails;

-- Funcion: suma, Ventana: total. Sacamos la suma del total
select productCode, quantityOrdered, sum(quantityOrdered) 
over() as Tot_unidades
from classicmodels.orderdetails;

-- Funcion: suma, Ventana: segmentada. Sacamos la suma segmentada por código de producto
select productCode, quantityOrdered, sum(quantityOrdered) 
over(partition by productCode) as Tot_unidades_por_prod0
from classicmodels.orderdetails;

-- Varias funciones de varias variables segmentadas por otra
select 
	productCode, 
	avg(priceEach) over(partition by productCode) as Precio_medio_por_prod, 
	sum(quantityOrdered) over(partition by productCode) as Tot_unidades_por_prod
from classicmodels.orderdetails;

-- VENTANAS PERSONALIZADAS

-- Todo lo anterior versión larga. Se trata de obtener el acumulado teniendo en cuenta las filas anteriores a la posicionada
select orderNumber, productCode, quantityOrdered, SUM(quantityOrdered) 
over (order by orderNumber, productCode, quantityOrdered rows between unbounded preceding and current row) as acumulado_anterior
from classicmodels.orderdetails;

-- Todo lo anterior versión corta. Sale el mismo resultado, por defecto hace el acumulado desde el registro anterior hasta el final
select orderNumber, productCode, quantityOrdered, SUM(quantityOrdered) 
over (order by orderNumber, productCode, quantityOrdered) as acumulado_anterior
from classicmodels.orderdetails;

-- Todo lo siguiente. El acumuado lo hace desde la fila en curso hacia adelante
select orderNumber, productCode, quantityOrdered, SUM(quantityOrdered) 
over (order by orderNumber, productCode, quantityOrdered rows between current row and unbounded following) as acumulado_siguiente
from classicmodels.orderdetails;

-- Con reseteo (segmentación) por otra variable
select orderNumber, productCode, quantityOrdered, SUM(quantityOrdered) 
over (partition by productCode order by orderNumber, quantityOrdered) as acumulado
from classicmodels.orderdetails;

-- Ventanas personalizadas n registros hacia atrás
select paymentDate, amount, sum(amount) 
over(order by paymentDate rows between 2 preceding and current row) as sum_tres_dias_atras
from classicmodels.payments;

-- Ventanas personalizadas n registros hacia adelante
select paymentDate, amount, sum(amount) 
over(order by paymentDate rows between current row and 2 following) as sum_tres_dias_adelante
from classicmodels.payments;

-- Las anteriores con cualquier función de agregación
select paymentDate, amount, max(amount) 
over(order by paymentDate rows between current row and 2 following) as max_tres_dias_adelante
from classicmodels.payments;

-- Las anteriores con el primer valor
select customerNumber, amount, first_value(amount) 
over(partition by customerNumber) as primera_compra_del_cliente
from classicmodels.payments;

-- Las anteriores con el último valor
select customerNumber, amount, last_value(amount) 
over(partition by customerNumber) as ultima_compra_del_cliente
from classicmodels.payments;

-- Las anteriores con un valor a elección
select customerNumber, amount, nth_value(amount,2) 
over(partition by customerNumber) as segunda_compra_del_cliente
from classicmodels.payments;

