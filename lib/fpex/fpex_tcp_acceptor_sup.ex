defmodule Fpex.TcpAcceptorSup do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    children = [
      worker(Fpex.TcpAcceptor, [], restart: :temporary, shutdown: 2000)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

end
