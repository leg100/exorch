defmodule SSHConnectionTest do
  use ExUnit.Case

  alias Exorch.SSH.Daemon
  alias Exorch.SSH.Connection

  setup_all do
    {:ok, port} = Daemon.start()
    {:ok, %{port: port}}
  end

  test "connect", %{port: port} do
    {status, ref} =
      with {:ok, conn} <- Connection.new(%{host: "localhost", port: port}),
        do: Connection.connect(conn)

    assert status == :ok
    assert is_pid(ref)
  end

  test "explicit authorized user", %{port: port} do
    {status, ref} =
      with {:ok, conn} <- Connection.new(%{
        user: System.get_env("USER"),
        host: "localhost",
        port: port
      }), do: Connection.connect(conn)

    assert status == :ok
    assert is_pid(ref)
  end

  test "unauthorized user", %{port: port} do
    {status, reason} =
      with {:ok, conn} <- Connection.new(%{
        user: "hacker",
        host: "localhost",
        port: port}), do: Connection.connect(conn)

    assert status == :error
    assert reason == 'Unable to connect using the available authentication methods'
  end

  test "explicit valid identity_file", %{port: port} do
    identity_file_path = Path.join(~w(#{System.user_home} .ssh id_rsa))
    {status, ref} =
      with {:ok, conn} <- Connection.new(%{
        host: "localhost",
        port: port,
        identity_file: identity_file_path}), do: Connection.connect(conn)

    assert status == :ok
    assert is_pid(ref)
  end

  test "non-existant identity file", %{port: port} do
    {status, reason} =
      with {:ok, conn} <- Connection.new(%{
        host: "localhost",
        port: port,
        identity_file: "blah"}), do: Connection.connect(conn)

    assert status == :error
    assert reason == "blah does not exist"
  end

  test "run command", %{port: port} do
    {:ok, ref} =
      with {:ok, conn} <- Connection.new(%{host: "localhost", port: port}),
        do: Connection.connect(conn)

    {stdout, stderr, exit_code} = Connection.run(ref, ~S/1 + 1./)

    assert stdout    == "2\n"
    assert stderr    == ""
    assert exit_code == 0
  end

  test "connection refused" do
    {status, reason} =
      with {:ok, conn} <- Connection.new(%{host: "localhost", port: 12334}),
        do: Connection.connect(conn)

    assert status == :error
    assert reason == :econnrefused
  end

  test "connection timeout" do
    {status, reason} =
      with {:ok, conn} <- Connection.new(%{
        host: "3.3.3.3",
        connect_timeout: 10}), do: Connection.connect(conn)

    assert status == :error
    assert reason == :timeout
  end
end
