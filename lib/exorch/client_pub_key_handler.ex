defmodule Exorch.ClientPubKeyHandler do
  @behaviour :ssh_client_key_api

  @default_identity_file Path.join(~w(#{System.user_home} .ssh id_rsa))

  def add_host_key(_hostnames, _key, _connect_opts) do
    :ok
  end

  def is_host_key(_key, _host, _algorithm, _connect_opts) do
    true
  end

  def user_key(algorithm, _connect_opts) when algorithm != :"ssh-rsa" do
    {:error, "unsupported user key algorithm"}
  end

  def user_key(_, connect_opts) do
    path = get_identity_file(connect_opts[:key_cb_private][:identity_file])

    case File.read(path) do
      {:ok, str} -> {:ok, decode_key(str)}
      {:error, :enoent} ->
        {:error, "ssh private key #{path} does not exist"}
    end
  end

  defp get_identity_file(nil), do: @default_identity_file
  defp get_identity_file(identity_file), do: identity_file

  defp decode_key(str) do
    :public_key.pem_decode(str)
    |> List.first
    |> :public_key.pem_entry_decode
  end
end
