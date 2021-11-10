defmodule Graph do

  def new(n) do
    control = spawn(fn -> controller(%{}, n) end)
    create_graph(Enum.map(1..n, fn _ ->
      spawn(fn ->
        loop(-1, control)
      end)
    end), %{}, n)
  end

  defp loop(state, controller) do
    receive do
      {:bfs, graph, new_state} ->
        if new_state > state and state != -1 do
          send(controller, {:done, self(), state});
          Process.sleep(5000)
        else
          state =
            cond do
              new_state < state -> new_state
              state == -1 -> new_state
              true -> state
            end
          vecinos = Map.get(graph, self())
          Enum.map(vecinos, fn vecino -> send(vecino, {:bfs, graph, state + 1}) end)
          loop(state, controller)
        end
      {:dfs, graph, new_state} -> :ok
      {:get_state, caller} -> #Estos mensajes solo los manda el main.

        send(caller, {self, state})
    end
  end

  defp create_graph([], graph, _) do
    graph
  end

  defp create_graph([pid | l], graph, n) do
    g = create_graph(l, Map.put(graph, pid, MapSet.new()), n)
    e = :rand.uniform(div(n*(n-1), 2))
    create_edges(g, e)
  end

  defp create_edges(graph, 0) do
    graph
  end

  defp create_edges(graph, n) do
    nodes = Map.keys(graph)
    create_edges(add_edge(graph, Enum.random(nodes), Enum.random(nodes)), n-1)
  end

  defp add_edge(graph, u, v) do
    cond do
      u == nil or v == nil -> graph
      u == v -> graph
      true ->
      	u_neighs = Map.get(graph, u)
      	new_u_neighs = MapSet.put(u_neighs, v)
      	graph = Map.put(graph, u, new_u_neighs)
      	v_neighs = Map.get(graph, v)
      	new_v_neighs = MapSet.put(v_neighs, u)
      	Map.put(graph, v, new_v_neighs)
    end
  end

  def random_src(graph) do
    Enum.random(Map.keys(graph))
  end

  def bfs(graph, src) do
    IO.puts("START:")
    IO.puts(inspect(src))

    send(src, {:bfs, graph, 0})

  end

  def controller(map, n) do #solo para mostrar los procesos cuando ya terminen
    receive do
      {:done, process, state} ->
        new = Map.put(map, process, state)
        IO.puts(inspect(process))
        IO.puts state
        if map_size(new) == n do
          IO.puts("termin[e]")
        else
          controller(new, n)
        end
    end
  end

  def bfs(graph) do
    bfs(graph, random_src(graph))
  end

  def dfs(graph, src) do
    :ok
  end

  def dfs(graph) do
    dfs(graph, random_src(graph))
  end

end
