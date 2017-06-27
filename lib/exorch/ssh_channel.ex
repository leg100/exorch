defmodule Exorch.SSHChannel do
  use GenServer

  defstruct conn_ref: nil,
    channel_id: nil,
    client: nil,
    stdout: "",
    stderr: "",
    exit_status: nil,
    closed: false,
    timeout: 5000,
    exec_timeout: 60000

  # interface

  def start(channel) do
    {:ok, pid} = GenServer.start(__MODULE__, channel)
    pid
  end

  def exec(pid, cmd) do
    GenServer.call(pid, {:exec, cmd})
  end


  # callbacks

  def init(%__MODULE__{conn_ref: ref, timeout: timeout} = channel) do
    {:ok, channel_id} = :ssh_connection.session_channel(ref, timeout)
    {:ok, %{channel | channel_id: channel_id}}
  end

  def handle_call({:exec, cmd}, from, channel) do
    :success = :ssh_connection.exec(channel.conn_ref, channel.channel_id,
      to_charlist(cmd), channel.timeout)

    {:noreply, %{channel | client: from}}
  end

  def handle_info({:ssh_cm, _, {:data, _, 0, stdout}}, channel) do
    {:noreply, %{channel | stdout: channel.stdout <> stdout}}
  end

  def handle_info({:ssh_cm, _, {:data, _, 1, stderr}}, channel) do
    {:noreply, %{channel | stderr: channel.stderr <> stderr}}
  end

  def handle_info({:ssh_cm, _, {:exit_status, _, exit_status}}, channel) do
    {:noreply, %{channel | exit_status: exit_status}}
  end

  def handle_info({:ssh_cm, _, {:eof, _}}, channel) do
    {:noreply, channel}
  end

  def handle_info({:ssh_cm, _, {:closed, _}}, channel) do
    GenServer.reply(channel.client, {channel.stdout, channel.stderr,
      channel.exit_status})
    {:stop, :normal, %{channel | closed: true}}
  end
end
