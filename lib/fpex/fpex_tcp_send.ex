defmodule Fpex.TcpSend do

  def send_and_close(socket, data) do
    IO.puts data

    IO.puts "#{inspect socket}"

    :gen_tcp.send(socket, data)
    :gen_tcp.close(socket)
  end
end
