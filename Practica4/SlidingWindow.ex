defmodule GeneratePackage do

  def new(n) do
    Enum.map(1..n, fn x -> num = :rand.uniform(2)-1 end)
  end
  
end

defmodule SlidingWindow do

  def new(n) do
    package = GeneratePackage.new(n)
    k = :rand.uniform(div(n, 2))
    sender = spawn(fn -> sender_loop(package, n, k) end)
    recvr = spawn(fn -> recvr_loop(sender) end)
  end

  def sender_loop(package, n, k) do
    receive do
      {:start,recvr}->send_pck(package,0,k,n,recvr)
                      sender_loop2(package,n,k,Enum.map(1..n, fn x->0 end))
    end
  end

  defp sender_loop2(package,n,k,received)do
    receive do
      {:got,id,recvr}->received=List.replace_at(received,id,1)
                  window_at=next_position(received,0)
                  send_pck(package,window_at,k,n,recvr)
                  if window_at<n do                    
                    sender_loop2(package,n,k,received)
                  else
                    receive do
                      {:finish,pid}->send(pid,{package})
                    end
                  end
    end
  end

  defp next_position([h|tail],i) do
    if h==0 do
      i
    else
      next_position(tail,i+1)
    end
  end

  defp next_position([],i) do
    i
  end
  defp send_pck(pck,id,k,tam,receiver)do
    if k>0&&id<tam do
      send(receiver,{:pack,id,Enum.at(pck,id)})
      send_pck(pck,id+1,k-1,tam,receiver)
    end
  end


  def recvr_loop(sender) do
    {:ok,pid}=Task.start(fn -> build_pck(sender,%{}) end)
    send(sender,{:start,pid})
  end
  
  defp build_pck(sender,map)do
    this=self()
    receive do
      {:pack,id,v}->send(sender,{:got,id,this})
                    build_pck(sender,Map.put(map,id,v))
      {:finish,pid}->send(pid,{map})
    end
  end
end
