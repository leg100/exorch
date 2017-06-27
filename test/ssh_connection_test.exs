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
    {status, ref} =
      %SSHConnection{host: "localhost", port: port}
      |> SSHConnection.connect()

    assert status == :ok
    assert is_pid(ref)
  end

  test "explicit authorized user", %{port: port} do
    {status, ref} =
      %SSHConnection{user: "louis", host: "localhost", port: port}
      |> SSHConnection.connect()

    assert status == :ok
    assert is_pid(ref)
  end

  test "unauthorized user", %{port: port} do
    {status, reason} =
      %SSHConnection{user: "bob", host: "localhost", port: port}
      |> SSHConnection.connect()

    assert status == :error
    assert reason == 'Unable to connect using the available authentication methods'
  end

  test "explicit valid identity_file", %{port: port} do
    identity_file_path = Path.join(~w(#{System.user_home} .ssh id_rsa))
    {status, ref} =
      %SSHConnection{
        host: "localhost",
        port: port,
        identity_file: identity_file_path}
      |> SSHConnection.connect()

    assert status == :ok
    assert is_pid(ref)
  end

  test "non-existant identity file", %{port: port} do
    {status, reason} =
      %SSHConnection{host: "localhost", port: port, identity_file: "blah"}
      |> SSHConnection.connect()

    assert status == :error
    assert reason == 'Unable to connect using the available authentication methods'
  end

  test "run command", %{port: port} do
    {:ok, ref} =
      %SSHConnection{host: "localhost", port: port}
      |> SSHConnection.connect()

    {stdout, stderr, exit_code} = SSHConnection.run(ref, ~S/1 + 1./)

    assert stdout    == "2\n"
    assert stderr    == ""
    assert exit_code == 0
  end

  test "connection refused" do
    {status, reason} =
      %SSHConnection{host: "localhost", port: 12334}
      |> SSHConnection.connect()

    assert status == :error
    assert reason == :econnrefused
  end

  test "connection timeout" do
    {status, reason} =
      %SSHConnection{host: "3.3.3.3", connect_timeout: 10}
      |> SSHConnection.connect()

    assert status == :error
    assert reason == :timeout
  end
end
