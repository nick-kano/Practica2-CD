defmodule Tree do

  def new(n) do
    create_tree(Enum.map(1..n, fn _ -> spawn(fn -> loop() end) end), %{}, 0)
  end

  defp loop() do
    receive do
      {:broadcast, tree, i, caller} ->
        if not hayHijoIzq(i,tree) do
          send(caller,{:acabe,self()})
        else
          send(Map.fetch!(tree,(2*i)+1),{:broadcast, tree, (2*i)+1, caller})
          if hayHijoDer(i,tree) do
            send(Map.fetch!(tree,(2*i)+2),{:broadcast, tree, (2*i)+2, caller})
          end
        end
      {:convergecast, tree, i, caller} ->
        if i==0 do
          send(caller,{:acabe,self()})
        else
          if not hayHijoIzq(i, tree) do
            sendPadre(tree,i,caller)
          else
            if not hayHijoDer(i, tree) do
              sendPadre(tree,i,caller)
            else
              receive do
                {:convergecast, tree, i, caller} -> 
                  sendPadre(tree,i,caller)
              end
            end
          end
        end
      {:broadconvergecast,tree,i,caller}->
        if not hayHijoIzq(i,tree) do
          if rem(i,2)==0 do
            send(Map.fetch!(tree,div(i-2,2)),{:broadconvergecast,tree,div(i-2,2),caller})
          else
            send(Map.fetch!(tree,div(i-1,2)),{:broadconvergecast,tree,div(i-1,2),caller})
          end
        else
          send(Map.fetch!(tree,(2*i)+1),{:broadconvergecast, tree, (2*i)+1, caller})
          if hayHijoDer(i,tree) do
            send(Map.fetch!(tree,(2*i)+2),{:broadconvergecast, tree, (2*i)+2, caller})
            loop2(2)
          else 
            loop2(1)
          end
        end
      {:convergebroadcast,tree,i,caller}->
        if i==0 do
          cbc(tree,i,caller)
        else
          if not hayHijoIzq(i,tree) do 
            sendPadrecbc(tree,i,caller)
            cbc(tree,i,caller)
          else
            if not hayHijoDer(i,tree) do
              sendPadrecbc(tree,i,caller)
              cbc(tree,i,caller)
            else
              receive do
                {:convergebroadcast,tree,i,caller}->
                  sendPadrecbc(tree,i,caller)
                  cbc(tree,i,caller)
              end
            end
          end
        end
      end
    end

    defp sendPadre(tree,i,caller) do
      if rem(i,2)==0 do
        send(Map.fetch!(tree,div(i-2,2)),{:convergecast,tree,div(i-2,2),caller})
      else
        send(Map.fetch!(tree,div(i-1,2)),{:convergecast,tree,div(i-1,2),caller})
      end
    end

    defp sendPadrecbc(tree,i,caller) do
      if rem(i,2)==0 do
        send(Map.fetch!(tree,div(i-2,2)),{:convergebroadcast,tree,div(i-2,2),caller})
      else
        send(Map.fetch!(tree,div(i-1,2)),{:convergebroadcast,tree,div(i-1,2),caller})
      end
    end

    defp loop2(n)do
      receive do
        {:broadconvergecast,tree,i,caller}->
          n=n-1
          if n==0 do
            this=self()
            if i==0 do
              send(caller,{:acabe,this})
            else
              if rem(i,2)==0 do
                send(Map.fetch!(tree,div(i-2,2)),{:broadconvergecast,tree,div(i-2,2),caller})
              else
                send(Map.fetch!(tree,div(i-1,2)),{:broadconvergecast,tree,div(i-1,2),caller})
              end
            end
          else
            loop2(n)
          end
      end
    end

  defp hayHijoIzq(ind, tree) do
    Map.has_key?(tree,2*ind+1)
  end

  defp hayHijoDer(ind, tree) do
    Map.has_key?(tree,2*ind+2)
  end

  defp create_tree([], tree, _) do
    tree
  end

  defp create_tree([pid | l], tree, pos) do
    create_tree(l, Map.put(tree, pos, pid), (pos+1))
  end

  def broadcast(tree, n) do
    numHojas=div((n+1),2)
    this=self()
    {:ok,pid}=Task.start(fn -> mensajes(numHojas,[],this) end)
    send(Map.fetch!(tree,0),{:broadcast, tree, 0, pid})
    receive do
      {:acabe ,l}->l
    end
  end

  defp mensajes(n,list,caller) do
    receive do
      {:acabe,pid}->
        if n==1 do
          l=list++[pid]
          send(caller,{:acabe,l})
        else
          mensajes(n-1,list++[pid],caller)
        end
    end
  end

  def convergecast(tree, n) do
    this=self()
    mandarHojas(listaHojas(n,div(n+1,2)), tree, this)
    receive do
      {:acabe,pid}->{:ok,pid}
    end
  end

  defp listaHojas(size, 1) do
    [size-1]
  end

  defp listaHojas(size, i) do
    [size-i]++listaHojas(size,i-1)
  end

  defp mandarHojas([x|xs], tree, pid)do
    send(Map.fetch!(tree,x),{:convergecast, tree, x, pid})
    mandarHojas(xs, tree, pid)
  end

  defp mandarHojas([],_,_)do
    :ok
  end
  

  def broadconvergecast(tree) do
    this=self()
    send(Map.fetch!(tree,0),{:broadconvergecast,tree,0,this})
    receive do
      {:acabe,pid}->{:ok,pid}
    end
  end

  def convergebroadcast(tree,n) do
    numHojas=div((n+1),2)
    this=self()
    {:ok,pid}=Task.start(fn -> mensajes(numHojas,[],this) end)
    mandarHojascbc(listaHojas(n,div(n+1,2)), tree, pid)
    receive do
      {:acabe,l}->l
    end
  end

  defp cbc(tree, i, caller) do
    if i==0 do
      if hayHijoIzq(i,tree) do
        send(Map.fetch!(tree,(2*i)+1),{:cbc, tree, (2*i)+1, caller})
        if hayHijoDer(i,tree) do
          send(Map.fetch!(tree,(2*i)+2),{:cbc, tree, (2*i)+2, caller})
        end
      end
    else
      receive do
      {:cbc, tree, i, caller} ->
        if not hayHijoIzq(i,tree) do
          send(caller,{:acabe,self()})
        else
          send(Map.fetch!(tree,(2*i)+1),{:cbc, tree, (2*i)+1, caller})
          if hayHijoDer(i,tree) do
            send(Map.fetch!(tree,(2*i)+2),{:cbc, tree, (2*i)+2, caller})
          end
        end
      end
    end
  end

  defp mandarHojascbc([x|xs], tree, pid) do
    send(Map.fetch!(tree,x),{:convergebroadcast, tree, x, pid})
    mandarHojascbc(xs, tree, pid)
  end

  defp mandarHojascbc([],_,_)do
    :ok
  end
end
