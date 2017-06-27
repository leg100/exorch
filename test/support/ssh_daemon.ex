defmodule Exorch.SSHDaemon do
  use GenServer

  alias Exorch.ServerPubKeyHandler

  @project_dir File.cwd!
  @sshd_dir Path.join(~w(#{@project_dir} test fixtures ssh_host_keys))

  def start() do
    {:ok, pid} = :ssh.daemon(0,
      system_dir:   to_charlist(@sshd_dir),
      auth_methods: 'publickey',
      key_cb:       {
        ServerPubKeyHandler,
        sshd_dir: @sshd_dir
      }
    )

    {:ok, [port: port]} = :ssh.daemon_info(pid)

    {:ok, port}
  end
end
