defmodule Fpex.TcpListenerSup do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(_opts) do

    listener_opts = %{
      port: 843,
      tcp_opts: [:binary, {:reuseaddr, true}, {:nodelay, true}, {:active, false}]
    }

    children = [
      supervisor(Fpex.TcpClientSup, [[name: Fpex.TcpClientSup]], restart: :transient, shutdown: :infinity),
      supervisor(Fpex.TcpAcceptorSup, [[name: Fpex.TcpAcceptorSup]], restart: :transient, shutdown: :infinity),
      worker(Fpex.TcpListener, [listener_opts], restart: :transient, shutdown: 100)
    ]

    supervise(children, strategy: :one_for_all)
  end

end
