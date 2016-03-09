defmodule Fpex.TcpListener do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    Process.flag(:trap_exit, true)
    port = Dict.fetch!(opts, :port)
    tcp_opts = Dict.fetch!(opts, :tcp_opts)
    case :gen_tcp.listen(port, tcp_opts) do
      {:ok, server_socket} ->
        {:ok, pid} = Supervisor.start_child(Fpex.TcpAcceptorSup, [server_socket])
        {:ok, server_socket}
      {:error, reason} ->
        Logger.error "failed to start flash polocy server #{reason}"
        {:stop, reason}
    end
  end

  def handle_call(_msg, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def terminate(_reason, state) do
    :gen_tcp.close(state)
    :ok
  end

  def code_change(_oldVsn, state, _extra) do
    {:ok, state}
  end

end
