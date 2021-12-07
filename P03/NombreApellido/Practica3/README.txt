--- INTEGRANTES ---
Nicolás Kano Chavira				315319204
Fernanda Garduño Ballesteros		317010316
Sebastián Alamina Ramírez			318685496
Carmen Paola Innes Barrón			317346741
Jean Durán Villanueva				316032416

--- EJECUCIÓN ---
1) Dentro de la carpeta "src", ejecutar el
archivo "Consensus.ex" desde el intérprete
de Elixir mediante el comando "iex Consensus.ex".

2) Ejecutar la función "Consensus.consensus(n)",
en donde "n" es el número de procesos a pariticipar
durante el consenso.

*) Si se desea más información durante la ejecución
del programa (por ejemplo, para depurar), es posible
descomentar las dos líneas dentro de la condición
"if(state == :fail) do" al principio de la función
privada "loop/4".

--- NOTAS ---
* Se agregó un parámetro a la función loop para
que los procesos puedan llevar un seguimiento
respecto a quiénes son sus vecinos.