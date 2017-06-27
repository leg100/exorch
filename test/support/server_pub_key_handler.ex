defmodule Exorch.ServerPubKeyHandler do
  @behaviour :ssh_server_key_api

  @project_dir File.cwd!
  @sshd_dir Path.join(~w(#{@project_dir} test fixtures ssh_host_keys))

  def is_auth_key(_key, 'louis', _daemon_opts), do: true
  def is_auth_key(_key, _user, _daemon_opts), do: false

  def host_key(:"ssh-rsa", _daemon_opts), do: {:ok, read_host_key("rsa")}
  def host_key(:"ssh-dss", _daemon_opts), do: {:ok, read_host_key("dsa")}
  def host_key(algorithm, _daemon_opts) do
    {:error, "Unsupported algorithm: #{algorithm}"}
  end

  defp read_host_key(algorithm) do
    Path.join(@sshd_dir, "ssh_host_#{algorithm}_key")
    |> File.read!()
    |> :public_key.pem_decode()
    |> List.first()
    |> :public_key.pem_entry_decode()
  end
end