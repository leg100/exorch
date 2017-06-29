defmodule Exorch.SSH.Daemon do
  use GenServer

  alias Exorch.SSH.ServerPubKeyHandler

  @sshd_dir Path.join(~w(test fixtures))

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
