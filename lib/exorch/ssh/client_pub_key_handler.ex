defmodule Exorch.SSH.ClientPubKeyHandler do
  @behaviour :ssh_client_key_api

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
    path = connect_opts[:key_cb_private][:identity_file]

    with {:ok, str} <- File.read(path), do: {:ok, decode_key(str)}
  end

  defp decode_key(str) do
    :public_key.pem_decode(str)
    |> List.first
    |> :public_key.pem_entry_decode
  end
end
