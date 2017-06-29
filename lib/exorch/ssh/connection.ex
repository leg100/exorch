defmodule Exorch.SSH.Connection do

  alias Exorch.SSH.Channel
  alias Exorch.SSH.ClientPubKeyHandler

  defstruct host:            nil,
            port:            22,
            identity_file:   "#{System.user_home}/.ssh/id_rsa",
            user:            nil,
            timeout:         5_000,
            connect_timeout: 10_000

  def new(opts) do
    struct!(__MODULE__, opts)
    |> check_existence_of_identity_file()
  end

  def check_existence_of_identity_file(%__MODULE__{} = conn) do
    case File.exists?(conn.identity_file) do
      true -> {:ok, conn}
      false -> {:error, "#{conn.identity_file} does not exist"}
    end
  end

  def connect(%__MODULE__{} = ssh_connection) do
    :ssh.connect(
      to_charlist(ssh_connection.host),
      ssh_connection.port,
      connect_opts(ssh_connection),
      ssh_connection.connect_timeout
    )
  end

  def run(ref, cmd) do
    %Channel{conn_ref: ref}
    |> Channel.start()
    |> Channel.exec(cmd)
  end

  defp connect_opts(%__MODULE__{} = ssh_connection) do
    [
      silently_accept_hosts: true,
      key_cb:                {
        ClientPubKeyHandler,
        identity_file:       ssh_connection.identity_file
      },
      connect_timeout: ssh_connection.connect_timeout,
      disconnectfun: &disconnect_msg/1,
      unexpectedfun: &unexpected_msg/2,
      ssh_msg_debug_fun: &ssh_debug_msg/4
    ]
    |> connect_opts_user(ssh_connection.user)
  end

  defp connect_opts_user(opts, nil), do: opts
  defp connect_opts_user(opts, user) do
    Keyword.merge(opts, user: to_charlist(user))
  end

  def disconnect_msg(msg) do
    IO.puts "disconnect_msg: #{msg}"
  end

  def unexpected_msg(msg, {host, port}) do
    IO.puts "unexpected_msg: #{msg}"
    :skip
  end

  def ssh_debug_msg(_, true, msg, _) do
    IO.puts "debug_msg: #{msg}"
  end
end
