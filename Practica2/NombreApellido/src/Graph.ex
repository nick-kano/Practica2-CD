defmodule Graph do

  def new(n) do
    create_graph(Enum.map(1..n, fn _ ->
      spawn(fn ->
        loop(-1)
      end)
    end), %{}, n)
  end

  defp loop(state) do
    receive do
      {:bfs, graph, new_state} ->
        state =
          cond do
            new_state < state -> new_state
            state == -1 -> new_state
            true -> state
          end
        vecinos = Map.get(graph, self())
        Enum.map(vecinos, fn vecino -> send(vecino, {:bfs, graph, state + 1})end)
        loop(state)
      {:dfs, graph, new_state} ->
        if (state == -1) do
          state = new_state
          vecinos = Map.get(graph, self())
          Enum.map(vecinos, fn x ->
            send(x, {:bfs, graph, new_state+1})
          end)
        end
        loop(state)
      {:get_state, caller} -> #Estos mensajes solo los manda el main.
        if state == -1 do
          Process.sleep(5000)
          send(self, {:get_state, caller})
          loop(state)
        else
          send(caller, {self, state})
        end
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
    get_states(0, map_size(graph), Map.keys(graph))
    receiver([], map_size(graph))
  end

  def get_states(count, n, nodes) do
    if count < n do
      send(Enum.at(nodes, count), {:get_state, self})
      get_states(count + 1, n, nodes)
    end
  end

  def receiver(list, n) do #solo para mostrar los procesos cuando ya terminen
    receive do
      {process, state} ->
        if (length(list) + 1) == n do
          list ++ [{process, state}]
        else
          receiver(list ++ [{process, state}], n)
        end
    end
  end

  def bfs(graph) do
    bfs(graph, random_src(graph))
  end

  def dfs(graph, src) do
    IO.puts("START:")
    IO.puts(inspect(src))
    send(src, {:dfs, graph, 0})
    get_states(0, map_size(graph), Map.keys(graph))
    receiver([], map_size(graph))
  end

  def dfs(graph) do
    dfs(graph, random_src(graph))
  end

end
