defmodule WaterCooler.DNSDiscovery do
  use GenServer

  @connect_interval 5_000 # try to connect every 5 seconds

  def start_link(hostname, opts \\ []) do
    hostname = to_charlist(hostname)
    GenServer.start_link(__MODULE__, hostname, opts)
  end

  def init(state) do
    send(self(), :refresh)
    {:ok, state}
  end

  def handle_info(:refresh, hostname) do
    ip_addresses = :inet_res.lookup(hostname, :in, :a)
    for {a, b, c, d} <- ip_addresses do
      Node.connect :"#{hostname}@#{a}.#{b}.#{c}.#{d}"
    end

    IO.puts "Nodes: #{inspect Node.list}"
    # IO.puts(Node.list |> length |> to_string)
    Process.send_after(self(), :refresh, @connect_interval)
    {:noreply, hostname}
  end
end
