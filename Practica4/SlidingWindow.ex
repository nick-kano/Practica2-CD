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
    :ok
  end

  def recvr_loop(sender) do
    :ok
  end
  
end
