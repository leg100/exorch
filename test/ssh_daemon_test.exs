defmodule SSHDaemonTest do
  use ExUnit.Case

  alias Exorch.SSHDaemon

  test "start daemon" do
    {status, port} = SSHDaemon.start()

    assert status == :ok
    assert is_integer(port)
    assert (port >= 1024 and port <= 65535)
  end

  test "can connect" do
    {:ok, port} = SSHDaemon.start()

    {status, ref} = :ssh.connect('localhost', port, silently_accept_hosts: true)

    assert status == :ok
    assert is_pid(ref)
  end
end
