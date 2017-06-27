defmodule SSHConnectionTest do
  use ExUnit.Case

  alias Exorch.SSHDaemon
  alias Exorch.SSHConnection

  setup_all do
    {:ok, daemon_pid} = SSHDaemon.start()
    :ok = SSHDaemon.start_daemon(daemon_pid)
    {:ok, port} = SSHDaemon.get_port(daemon_pid)

    {:ok, %{port: port}}
  end

  test "connect", %{port: port} do
    status =
      %SSHConnection{host: "localhost", port: port}
      |> SSHConnection.connect()

    assert status == {:ok, ref}
  end

  test "explicit authorized user", %{port: port} do
    pid =
      %SSHConnection{user: "louis", host: "localhost", port: port}
      |> SSHConnection.start()

    assert :connected = SSHConnection.connect(pid)
  end

  test "unauthorized user", %{port: port} do
    pid =
      %SSHConnection{user: "bob", host: "localhost", port: port}
      |> SSHConnection.start()

    assert {:error, _} = SSHConnection.connect(pid)
  end

  test "explicit valid identity_file", %{port: port} do
    identity_file_path = Path.join(~w(#{System.user_home} .ssh id_rsa))
    pid =
      %SSHConnection{
        host: "localhost",
        port: port,
        identity_file: identity_file_path}
      |> SSHConnection.start()

    assert :connected = SSHConnection.connect(pid)
  end

  test "non-existant identity file", %{port: port} do
    pid =
      %SSHConnection{host: "localhost", port: port, identity_file: "blah"}
      |> SSHConnection.start()

    assert {:error, _} = SSHConnection.connect(pid)
  end

  test "run command", %{port: port} do
    pid =
      %SSHConnection{host: "localhost", port: port}
      |> SSHConnection.start()

    :connected = SSHConnection.connect(pid)

    {stdout, stderr, exit_code} = SSHConnection.run(pid, ~S/1 + 1./)

    assert stdout    == "2\n"
    assert stderr    == ""
    assert exit_code == 0
  end

  test "connection refused" do
    pid =
      %SSHConnection{host: "localhost", port: 12334}
      |> SSHConnection.start()

    assert {:error, :econnrefused} = SSHConnection.connect(pid)
  end

  test "connection timeout" do
    pid =
      %SSHConnection{host: "3.3.3.3", connect_timeout: 10}
      |> SSHConnection.start()

    assert {:error, :timeout} = SSHConnection.connect(pid)
  end
end
