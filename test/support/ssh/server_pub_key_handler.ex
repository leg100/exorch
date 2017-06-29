defmodule Exorch.SSH.ServerPubKeyHandler do
  @behaviour :ssh_server_key_api

  @public_key "test/fixtures/id_rsa.pub"

  def is_auth_key(key, user, _daemon_opts) do
    {pub_key, _} = File.read!(@public_key)
      |> :public_key.ssh_decode(:public_key)
      |> List.first()

    valid_user(user) and key == pub_key
  end

  defp valid_user(user) do
    to_string(user) == System.get_env("USER")
  end

  def host_key(:"ssh-rsa", daemon_opts) do
    {:ok, read_host_key("rsa", daemon_opts)}
  end
  def host_key(:"ssh-dss", daemon_opts) do
    {:ok, read_host_key("dsa", daemon_opts)}
  end
  def host_key(algorithm, _daemon_opts) do
    {:error, "Unsupported algorithm: #{algorithm}"}
  end

  defp read_host_key(algorithm, daemon_opts) do
    daemon_opts[:key_cb_private][:sshd_dir]
    |> Path.join("ssh_host_#{algorithm}_key")
    |> File.read!()
    |> :public_key.pem_decode()
    |> List.first()
    |> :public_key.pem_entry_decode()
  end
end
