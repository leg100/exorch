defmodule SSHDaemonTest do
  use ExUnit.Case

  alias Exorch.SSH.Daemon

  test "start daemon" do
    {status, port} = Daemon.start()

    assert status == :ok
    assert is_integer(port)
    assert port in 1024..65535
  end
end
