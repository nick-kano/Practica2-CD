defmodule Tree do

  def new(n) do
    create_tree(Enum.map(1..n, fn _ -> spawn(fn -> loop() end) end), %{}, 0)
  end

  defp loop() do
    receive do
      {:broadcast, tree, i, caller} ->
        if esHoja(i) do
          send(caller,{:acabe})
        else
          if hayHijoIzq?(i,tree) do
            send(Map.fetch(tree,2*i+1),{:broadcast, tree, 2*i+1, caller})
          end
          if hayHijoDer?(i,tree) do
            send(Map.fetch(tree,2*i+2),{:broadcast, tree, 2*i+2, caller})
          end
        end
      {:convergecast, tree, i, caller} -> :ok #Aquí va su código.
    end
  end

  defp hayHijoIzq(int, tree) do
    Map.has_key(tree,2*int+1)
  end

  defp hayHijoDer(int, tree) do
    Map.has_key(tree,2*int+2)
  end

  defp create_tree([], tree, _) do
    tree
  end

  defp create_tree([pid | l], tree, pos) do
    create_tree(l, Map.put(tree, pos, pid), (pos+1))
  end

  def broadcast(tree, n) do
    hojas=div((2*n+1)/2,1)
    {:ok,pid}=Task.start(fn -> mensajes(hojas) end)
    send(Map.fetch(tree,0),{:broadcast, tree, 0, pid})
  end

  defp mensajes(n) do
    if n==0 do
      :broadcast_over
    else
      receive do
        {:acabe}->mensajes(n-1)
      end
    end
  end

  def convergecast(tree, n) do
    #Aquí va su código.
    :ok
  end
  
end
