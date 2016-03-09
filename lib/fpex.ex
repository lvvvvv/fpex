defmodule Fpex do
  use Application

  def start(_type, _args) do
    Fpex.TcpListenerSup.start_link()
  end
end
