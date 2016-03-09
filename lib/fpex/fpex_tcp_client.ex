defmodule Fpex.TcpClient do

  require Logger

  @header_len 4
  @timeout 5000

  @fp_xml <<"<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\" /></cross-domain-policy>", 0>>

  def start_link() do
    pid = spawn(fn -> init() end)
    {:ok, pid}
  end

  def init() do
    Process.flag(:trap_exit, true)
    receive do
      {:go, socket} ->
        read(socket)
    end
  end

  def read(socket) do
    async_recv(socket, @header_len, @timeout)
    receive do
      {:inet_async, socket, _ref, {:ok, <<"<pol">>}} ->
        # read the rest of data
        # rest = 23 - @header_len
        :prim_inet.send(socket, @fp_xml)
        :prim_inet.close(socket)
      {:inet_async, socket, _ref, {:error, :timeout}} ->
        close_peer(socket, {:error, :timeout})
      other ->
        close_peer(socket, other)
    end
  end

  def close_peer(socket, reason) do
    :prim_inet.close(socket)
    exit({:unexpected_message, reason})
  end

  def async_recv(socket, data_len, timeout) do
    case :prim_inet.async_recv(socket, data_len, timeout) do
      {:ok, res} -> res
      error -> error
    end
  end
end
