defmodule Exorch.SSHDaemon do
  use GenServer

  @project_dir File.cwd!
  @sshd_dir Path.join(~w(#{@project_dir} test fixtures ssh_host_keys))

  def start() do
    GenServer.start(__MODULE__, nil)
  end

  def start_daemon(pid) do
    GenServer.call(pid, :start)
  end

  def get_port(pid) do
    GenServer.call(pid, :get_port)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(:start, _from, _state) do
    {:ok, pid} = :ssh.daemon(0,
      system_dir: to_charlist(@sshd_dir),
      auth_methods: 'publickey',
      key_cb: Exorch.ServerPubKeyHandler
    )

    {:reply, :ok, pid}
  end

  def handle_call(:get_port, _from, pid) do
    {:ok, [port: port]} = :ssh.daemon_info(pid)

    {:reply, {:ok, port}, pid}
  end
end
