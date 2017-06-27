defmodule Exorch.Executor do
  use GenServer

  alias Exorch.SSHConnection

  defstruct ssh_connection: nil, cmd: nil

  def start(%__MODULE__{} = executor) do
    {:ok, pid} = GenServer.start(__MODULE__, executor)
    pid
  end

  def run(pid) do
    GenServer.cast(pid, :run)
  end

  def init(%__MODULE__{} = executor) do
    {:ok, executor}
  end

  def handle_cast(:run, %__MODULE__{} = executor) do
    pid = SSHConnection.start(executor.ssh_connection)

    status = SSHConnection.connect(pid)
    IO.puts status
    IO.puts "after connect"
    case status do
      :connected -> exec(pid, executor.cmd, executor)
      {:error, reason} -> {:stop, {:shutdown, reason}, executor}
      error -> {:stop, {:shutdown, error}, executor}
    end
  end

  def terminate(:normal, %__MODULE__{} = _executor) do
    # do nothing
    IO.puts "normal"
  end

  def terminate({:shutdown, reason}, %__MODULE__{} = _executor) do
    IO.puts "error"
    IO.inspect reason
  end

  defp exec(pid, cmd, %__MODULE__{} = executor) do
    SSHConnection.run(pid, cmd) |> format_output()

    {:stop, :normal, executor}
  end

  defp format_output({stdout, stderr, exit_code}) do
    IO.puts "stdout: #{stdout}"
    IO.puts "stderr: #{stderr}"
    IO.puts "exit_code: #{exit_code}"
  end
end

