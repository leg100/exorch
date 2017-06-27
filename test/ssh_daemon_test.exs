defmodule SSHDaemonTest do
  use ExUnit.Case

  alias Exorch.SSHDaemon

  setup_all do
    {:ok, pid} = SSHDaemon.start()
    {:ok, %{pid: pid}}
  end

  test "start daemon", %{pid: pid} do
    assert SSHDaemon.start_daemon(pid)
  end

  test "has listening port", %{pid: pid} do
    SSHDaemon.start_daemon(pid)
    {:ok, port} = SSHDaemon.get_port(pid)

    assert is_integer(port)
  end

  test "can connect", %{pid: pid} do
    SSHDaemon.start_daemon(pid)
    {:ok, port} = SSHDaemon.get_port(pid)

    {:ok, ref} = :ssh.connect('localhost', port, silently_accept_hosts: true)
    assert is_pid(ref)
  end
end
