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
    # loop(:start, 0, probabilidad_de_ser_un_proceso_fallido, lista de vecinos).
    Enum.map(1..n, fn _ ->
      spawn(fn -> loop(:start, 0, :rand.uniform(10), []) end)
    end)

    # Agregar código aquí es válido.
    # Sin embargo, requerimos que el Enum.map
    # sea lo último, para devolver una lista.

  end # <- Fin de la función create_consensus/1.

  # Función loop. Es la función
  # que cada proceso ejecuta.
  defp loop(state, value, miss_prob, neighbours) do

    # Inicia código inamovible...
    if(state == :fail) do
      # IO.puts ( "Fallé uwu soy el proceso de ID " <> inspect(self()) ) # CÓDIGO TEMPORAL PARA DEPURAR.
      # Process.exit(self(), :fail) # CÓDIGO TEMPORAL PARA DEPURAR.
      loop(state, value, miss_prob, neighbours) # Un proceso fallido se queda estancado aquí uwu.
    end
    # Termina código inamovible.

    receive do
      {:get_value, caller} -> send(caller, value) # No modificar.
      # Aquí se pueden definir más mensajes.
      {:neighbours, list} -> loop(state, value, miss_prob, list) # Define la lista de procesos de este proceso.
      {:set_value, x} -> if x < value do # Recepción del "value" de algún otro proceso. Continúo con el mínimo.
        loop(state, x, miss_prob, neighbours)
      else
        loop(state, value, miss_prob, neighbours)
      end
    after
      1000 -> :ok # Analizar por qué está esto aquí.
      # Si esto no estuviera aquí, los procesos se quedarían estancados
      # dentro de este "receive do" desde el principio; es decir, desde
      # antes de siquiera cambiar su "state" que inició en :start y, por
      # lo tanto, ni decidirían su valor aleatorio entre 1 y 10,000.
    end

    case state do
      :start -> # Inicialmente, hacer...
        chosen = :rand.uniform(10000) # ...escoger un valor aleatorio entre 1 y 10,000.
        if(rem(chosen, miss_prob) == 0) do # ...decidir si soy un proceso fallido o no.
          loop(:fail, chosen, miss_prob, neighbours) # ...en caso de que sí; fallar.
        else
          loop(:active, chosen, miss_prob, neighbours) # ...en caso de que no; continuar.
        end
      :fail -> loop(:fail, value, miss_prob, neighbours) # Si soy fallido; fallar.
      :active -> for p <- neighbours do # Si soy un proceso correcto, por cada proceso vecino...
        send(p, {:set_value, value}) # ...le envío mi "value".
      end
        loop(:sent, value, miss_prob, neighbours) # Y continúo mi ejecución como proceso que ya mandó su "value".
      :sent -> loop(state, value, miss_prob, neighbours) # Loopeo para seguir recibiendo valores de mis vecinos.

    end # <- Fin del "case state do".

  end # <- Fin de la función loop/4.

  # Función consensus. Regresa el valor
  # final escogido de manera unánime por
  # todos los hilos.
  def consensus(processes) do

    # Creamos tantos procesos como se indica en la función,
    # y almacenamos en una lista "l" los PID's.
    l = create_consensus(processes)

    # Le decimos a cada proceso quiénes son sus vecinos.
    # Estamos creando una gráfica completa.
    for p <- l do
      send(p, {:neighbours, List.delete(l,p)})
    end

    # Esperamos al consenso uwu.
    IO.puts("Consenso en proceso...")
    Process.sleep(5000) # Modificar la cantidad de milisegundos según el funcionamiento del código.
    IO.puts("Consenso terminado.")

    # Observamos el valor decidido de cada proceso.
    for p <- l do # Por cada proceso que se creó...
      send(p, {:get_value, self()}) # ...le pedimos su valor escogido.
      receive do
        # ...y lo imprimimos.
        value -> IO.puts( "El proceso de ID " <> inspect(p) <> " decidió el valor: " <> inspect(value) )
      after
        # Si no hay respuesta, tenemos un proceso fallido.
        100 -> IO.puts( "El proceso de ID " <> inspect(p) <> " falló." )
      end
    end

    "Fin de la ejecución."

  end # <- Fin de la función consensus/1.

end # <- Fin del módulo Consensus.