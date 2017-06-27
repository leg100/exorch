defmodule Exorch.ServerPubKeyHandler do
  @behaviour :ssh_server_key_api

  def is_auth_key(_key, user, _daemon_opts) do
    IO.puts "user is #{to_string(user)}"
    IO.puts ~s(local user is #{System.get_env("USER")})
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
    IO.inspect algorithm
    IO.inspect daemon_opts
    daemon_opts[:key_cb_private][:sshd_dir]
    |> Path.join("ssh_host_#{algorithm}_key")
    |> File.read!()
    |> :public_key.pem_decode()
    |> List.first()
    |> :public_key.pem_entry_decode()
  end
end
