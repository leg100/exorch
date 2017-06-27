defmodule Exorch.Response do
  defstruct stdout:    "",
            stderr:    "",
            exit_code: -1,
            error:     false,
            reason:    "",
            instance: nil


  def create({:error, reason}, instance) do
    %__MODULE__{instance: instance, error: true, reason: reason}
 end
  def create({stdout, stderr, exit_code}, instance) do
    %__MODULE__{
      instance:  instance,
      stdout:    String.trim(stdout),
      stderr:    String.trim(stderr),
      exit_code: exit_code
    }
  end

  def format_output(%__MODULE__{error: true} = resp) do
    %{host: resp.instance.dns_name, error: resp.reason}
    |> Poison.encode!()
  end
  def format_output(%__MODULE__{} = resp) do
    %{
      host:      resp.instance.dns_name,
      stdout:    resp.stdout,
      stderr:    resp.stderr,
      exit_code: resp.exit_code
    }
    |> Poison.encode!()
  end

  def success?(%__MODULE__{error: error, exit_code: exit_code}) do
    (not error) and (exit_code == 0)
  end
end
