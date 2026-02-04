Para crear estructura de filas podemos agregar columna personalizada y escribir el siguiente código para crear 
la columna en la que quiero reflejar por ejemplo los 12 meses del año.

Table.AddColumn(#"Conservar filas superiores", "Mes", each {1..12})