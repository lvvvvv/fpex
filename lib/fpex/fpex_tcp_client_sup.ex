defmodule Fpex.TcpClientSup do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    children = [
      worker(Fpex.TcpClient, [], restart: :temporary, shutdown: :brutal_kill)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

end
