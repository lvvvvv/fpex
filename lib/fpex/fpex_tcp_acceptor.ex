defmodule Fpex.TcpAcceptor do
  use GenServer
  require Logger

  @initial_state %{
    socket: nil,
    ref: nil
  }

  def start_link(server_socket) do
    GenServer.start_link(__MODULE__, server_socket)
  end

  def init(server_socket) do
    GenServer.cast(self(), :accept)
    {:ok, server_socket}
  end

  def handle_call(_req, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(:accept, state) do
    accept(state)
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  def handle_info({:inet_async, _server_socket, _ref, {:ok, client_socket}}, state) do
    # case set_sockopt(server_socket, client_socket) do
    #   :ok -> :ok
    #   {:error, reason} -> exit({:set_sockopt, reason})
    # end
    start_client(client_socket)
    accept(state)
  end

  def handle_info({:inet_async, _server_socket, _ref, {:error, :closed}}, state) do
    {:stop, :normal, state}
  end

  def handle_info(_info, state) do
    {:noreply, state}
  end

  def code_change(_oldVsn, state, _extra) do
    {:ok, state}
  end

  def terminate(_reason, state) do
    :gen_tcp.close(state)
    :ok
  end

  # def set_sockopt(server_socket, client_socket) do
  #   true = :inet_db.register_socket(client_socket, :inet_tcp)
  #   case :prim_inet.getopts(server_socket, [:active, :nodelay, :keepalive, :delay_send, :priority, :tos]) do
  #     {:ok, opts} ->
  #       case :prim_inet.setopts(client_socket, opts) do
  #         :ok -> :ok
  #         error ->
  #           :gen_tcp.close(client_socket)
  #           error
  #       end
  #     error ->
  #       :gen_tcp.close(client_socket)
  #       error
  #   end
  # end

  defp accept(state) do
    case :prim_inet.async_accept(state, -1) do
      {:ok, _ref} ->
        {:noreply, state}
      {:error, reason} ->
        {:stop, {:cannot_accept, reason}, state}
    end
  end

  defp start_client(client_socket) do
    {:ok, child} = Supervisor.start_child(Fpex.TcpClientSup, [])
    :ok = :gen_tcp.controlling_process(client_socket, child)
    send(child, {:go, client_socket})
  end


end
