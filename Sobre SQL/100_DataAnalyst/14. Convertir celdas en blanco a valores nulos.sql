UPDATE tu_tabla
SET tu_columna = IF(tu_columna = '', NULL, tu_columna)
WHERE tu_columna = '';