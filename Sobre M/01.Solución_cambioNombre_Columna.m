if Table.HasColumns(#"Encabezados promovidos", "horas_extra")
      then Table.RenameColumns(#"Encabezados promovidos", {{"horas_extra", "horas_extras"}})
      else #"Encabezados promovidos"