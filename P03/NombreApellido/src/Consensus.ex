# Task: Completar las funciones loop y consensus para que,
# al final de un número de ejecuciones de loop,
# todos los hilos tengan el mismo número decidido,
# el cual será enviado al hilo principal
# (mediante un mensaje en consensus).
defmodule Consensus do

  # Función que crea n hilos.
  # Cada hilo escogerá un número al azar.
  def create_consensus(n) do

    # La función anónima de cada proceso será
    # loop(:start, 0, probabilidad_de_ser_un_proceso_fallido).
    Enum.map(1..n, fn _ ->
      spawn(fn -> loop(:start, 0, :rand.uniform(10)) end)
    end)

    #Agregar código aquí es válido.

  end # <- Fin de la función create_consensus/1.

  # Función loop. Es la función
  # que cada proceso ejecuta.
  defp loop(state, value, miss_prob) do

    # Inicia código inamovible...
    if(state == :fail) do
      loop(state, value, miss_prob) # Un proceso fallido se queda estancado aquí uwu.
    end
    # Termina código inamovible.

    receive do
      {:get_value, caller} -> send(caller, value) # No modificar.
      # Aquí se pueden definir más mensajes.
    after
      1000 -> IO.puts("Analizar esto.") #:ok # Analizar porqué está esto aquí.
    end

    case state do
      :start -> # Inicialmente, hacer...
        chosen = :rand.uniform(10000) # ...escoger un valor aleatorio entre 1 y 10,000.
        if(rem(chosen, miss_prob) == 0) do # ...decidir si soy un proceso fallido o no.
          loop(:fail, chosen, miss_prob) # ...en caso de que sí; fallar.
        else
          loop(:active, chosen, miss_prob) # ...en caso de que no; continuar.
        end
      :fail -> loop(:fail, value, miss_prob) # Si soy fallido; fallar.
      :active -> :ok # Aquí va su código (de proceso correcto).

    end # <- Fin del "case state do".

  end # <- Fin de la función loop/3.

  # Función consensus. Regresa el valor
  # final escogido de manera unánime por
  # todos los hilos.
  def consensus(processes) do
    #Process.sleep(10000)
    # Aquí va su código, deben de regresar el valor
    # unánime decidido por todos los procesos.
    create_consensus(3)
    #:ok
  end # <- Fin de la función consensus/1.

end # <- Fin del módulo Consensus.